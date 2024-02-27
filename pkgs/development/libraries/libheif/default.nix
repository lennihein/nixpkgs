{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, autoreconfHook
, pkg-config
, dav1d
, rav1e
, libde265
, x265
, libpng
, libjpeg
, libaom

# for passthru.tests
, gimp
, imagemagick
, imlib2Full
, imv
, vips
}:

stdenv.mkDerivation rec {
  pname = "libheif";
  version = "1.14.0";

  outputs = [ "bin" "out" "dev" "man" ];

  src = fetchFromGitHub {
    owner = "strukturag";
    repo = "libheif";
    rev = "v${version}";
    sha256 = "sha256-MvCiVAHM9C/rxeh6f9Bd13GECc2ladEP7Av7y3eWDcY=";
  };

  patches = [
    (fetchpatch {
      name = "CVE-2023-29659.patch";
      url = "https://github.com/strukturag/libheif/commit/e05e15b57a38ec411cb9acb38512a1c36ff62991.patch";
      sha256 = "sha256-CobaQnSiNboQAlBTpsNS3TYIqnjTQLShZYCd3ZcGDo0=";
    })
  ];

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [ dav1d rav1e libde265 x265 libpng libjpeg libaom ];

  enableParallelBuilding = true;

  passthru.tests = {
    inherit gimp imagemagick imlib2Full imv vips;
  };

  meta = {
    homepage = "http://www.libheif.org/";
    description = "ISO/IEC 23008-12:2017 HEIF image file format decoder and encoder";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ gebner ];
  };
}
