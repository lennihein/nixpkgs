{ lib
, buildPlatform
, hostPlatform
, fetchurl
, bash
, tinycc
, gnumake
, gnupatch
, gnused
, gnugrep
}:
let
  pname = "gawk";
  # >=3.1.x is incompatible with mes-libc
  version = "3.0.6";

  src = fetchurl {
    url = "mirror://gnu/gawk/gawk-${version}.tar.gz";
    sha256 = "1z4bibjm7ldvjwq3hmyifyb429rs2d9bdwkvs0r171vv1khpdwmb";
  };

  patches = [
    # for reproducibility don't generate date stamp
    ./no-stamp.patch
  ];
in
bash.runCommand "${pname}-${version}" {
  inherit pname version;

  nativeBuildInputs = [
    tinycc.compiler
    gnumake
    gnupatch
    gnused
    gnugrep
  ];

  passthru.tests.get-version = result:
    bash.runCommand "${pname}-get-version-${version}" {} ''
      ${result}/bin/awk --version
      mkdir $out
    '';

  meta = with lib; {
    description = "GNU implementation of the Awk programming language";
    homepage = "https://www.gnu.org/software/gawk";
    license = licenses.gpl3Plus;
    maintainers = teams.minimal-bootstrap.members;
    platforms = platforms.unix;
  };
} ''
  # Unpack
  ungz --file ${src} --output gawk.tar
  untar --file gawk.tar
  rm gawk.tar
  cd gawk-${version}

  # Patch
  ${lib.concatMapStringsSep "\n" (f: "patch -Np0 -i ${f}") patches}

  # Configure
  export CC="tcc -static -B ${tinycc.libs}/lib"
  export ac_cv_func_getpgrp_void=yes
  export ac_cv_func_tzset=yes
  bash ./configure \
    --build=${buildPlatform.config} \
    --host=${hostPlatform.config} \
    --disable-nls \
    --prefix=$out

  # Build
  make gawk

  # Install
  install -D gawk $out/bin/gawk
  ln -s gawk $out/bin/awk
''
