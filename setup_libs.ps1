# setup_libs.ps1
$ErrorActionPreference = "Stop"

# Create directories
Write-Host "Creating directories..."
New-Item -ItemType Directory -Force -Path "libs", "res", "res/noto"

$SHALLOW = "--depth 1"

function Git-Clone-If-Missing($path, $url, $CloneArgsString) {
    if (-not (Test-Path "$path/.git")) {
        Write-Host "Cloning $path from $url..."
        $argsList = $CloneArgsString -split ' '
        git clone $url $argsList $path
    } else {
        Write-Host "$path already exists, skipping clone."
    }
}

# Clones matching Makefile
Git-Clone-If-Missing "libs/cairo" "https://gitlab.freedesktop.org/cairo/cairo.git" "$SHALLOW --branch 1.18.0 --single-branch --recurse-submodules"
Git-Clone-If-Missing "libs/libffi" "https://github.com/libffi/libffi.git" "$SHALLOW --branch v3.4.4 --single-branch"
Git-Clone-If-Missing "libs/cgal" "https://github.com/CGAL/cgal.git" "$SHALLOW --branch v6.0.1 --single-branch"
Git-Clone-If-Missing "libs/eigen" "https://gitlab.com/libeigen/eigen.git" "$SHALLOW --branch 3.4.0 --single-branch"
Git-Clone-If-Missing "libs/fontconfig" "https://gitlab.freedesktop.org/fontconfig/fontconfig" "$SHALLOW --branch 2.14.2 --single-branch"
Git-Clone-If-Missing "libs/freetype" "https://github.com/freetype/freetype.git" "$SHALLOW --branch VER-2-12-1 --single-branch"
Git-Clone-If-Missing "libs/glib" "https://github.com/kleisauke/glib.git" "$SHALLOW --branch wasm-vips-2.83.2 --single-branch"
Git-Clone-If-Missing "libs/harfbuzz" "https://github.com/harfbuzz/harfbuzz.git" "$SHALLOW --branch 8.3.0 --single-branch"
Git-Clone-If-Missing "libs/lib3mf" "https://github.com/3MFConsortium/lib3mf.git" "$SHALLOW --branch v2.3.2 --recurse-submodules"
Git-Clone-If-Missing "libs/libexpat" "https://github.com/libexpat/libexpat" "$SHALLOW --branch R_2_5_0 --single-branch"
Git-Clone-If-Missing "libs/liblzma" "https://github.com/tukaani-project/xz.git" "$SHALLOW --branch v5.4.1 --single-branch"
Git-Clone-If-Missing "libs/libzip" "https://github.com/nih-at/libzip.git" "$SHALLOW --branch v1.10.1 --single-branch"
Git-Clone-If-Missing "libs/zlib" "https://github.com/madler/zlib.git" "$SHALLOW --branch v1.2.13 --single-branch"
Git-Clone-If-Missing "libs/libxml2" "https://gitlab.gnome.org/GNOME/libxml2.git" "$SHALLOW --branch v2.12.5 --single-branch"
Git-Clone-If-Missing "libs/doubleconversion" "https://github.com/google/double-conversion" "$SHALLOW --branch v3.3.1 --single-branch"
Git-Clone-If-Missing "libs/openscad" "https://github.com/openscad/openscad.git" "$SHALLOW --branch master --single-branch --recurse-submodules"

# Resources
Git-Clone-If-Missing "res/liberation" "https://github.com/shantigilbert/liberation-fonts-ttf.git" "$SHALLOW --branch master --single-branch"
Git-Clone-If-Missing "res/MCAD" "https://github.com/openscad/MCAD.git" "$SHALLOW --branch master --single-branch"

# Downloads
Write-Host "Downloading tarballs..."
if (-not (Test-Path "libs/boost")) {
    Invoke-WebRequest -Uri "https://github.com/boostorg/boost/releases/download/boost-1.87.0/boost-1.87.0-b2-nodocs.tar.xz" -OutFile "boost.tar.xz"
    tar xf "boost.tar.xz" -C libs
    Move-Item "libs/boost-1.87.0" "libs/boost"
    Remove-Item "boost.tar.xz"
    (Get-Content "libs/boost/tools/build/src/tools/emscripten.jam") -replace "-fwasm-exceptions", "-fexceptions" | Set-Content "libs/boost/tools/build/src/tools/emscripten.jam"
}
if (-not (Test-Path "libs/gmp")) {
    Invoke-WebRequest -Uri "https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz" -OutFile "gmp.tar.xz"
    tar xf "gmp.tar.xz" -C libs
    Move-Item "libs/gmp-6.3.0" "libs/gmp"
    Remove-Item "gmp.tar.xz"
}
if (-not (Test-Path "libs/mpfr")) {
    Invoke-WebRequest -Uri "https://www.mpfr.org/mpfr-4.2.1/mpfr-4.2.1.tar.xz" -OutFile "mpfr.tar.xz"
    tar xf "mpfr.tar.xz" -C libs
    Move-Item "libs/mpfr-4.2.1" "libs/mpfr"
    Remove-Item "mpfr.tar.xz"
}
if (-not (Test-Path "res/noto/NotoSans-Regular.ttf")) {
    Invoke-WebRequest -Uri "https://github.com/openmaptiles/fonts/raw/master/noto-sans/NotoSans-Regular.ttf" -OutFile "res/noto/NotoSans-Regular.ttf"
    Invoke-WebRequest -Uri "https://github.com/openmaptiles/fonts/raw/master/noto-sans/NotoNaskhArabic-Regular.ttf" -OutFile "res/noto/NotoNaskhArabic-Regular.ttf"
}

# Meson crossfile
Copy-Item "emscripten-crossfile.meson" "libs/emscripten-crossfile.meson"

# Apply Patches
Write-Host "Applying patches..."
git -C libs/fontconfig apply ../../patches/fontconfig.patch
git -C libs/lib3mf apply ../../patches/lib3mf.patch

Write-Host "Setup complete!"
