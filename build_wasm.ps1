# build_wasm.ps1
$ErrorActionPreference = "Stop"

$CMAKE_BUILD_TYPE = "Release"
$MESON_BUILD_TYPE = "release"
$EMSCRIPTEN_FLAGS = "-fexceptions -O3"
$EMSCRIPTEN_SDK_TAG = "emscripten/emsdk:3.1.34"
$DOCKER_TAG_BASE = "openscad/wasm-base-release"
$DOCKER_TAG_OPENSCAD = "openscad/wasm-release"

Write-Host "Starting Docker Build Stage 1: Base Image..."
docker build libs `
    -f Dockerfile.base `
    -t $DOCKER_TAG_BASE `
    --build-arg "CMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE" `
    --build-arg "MESON_BUILD_TYPE=$MESON_BUILD_TYPE" `
    --build-arg "EMSCRIPTEN_FLAGS=$EMSCRIPTEN_FLAGS" `
    --build-arg "EMSCRIPTEN_SDK_TAG=$EMSCRIPTEN_SDK_TAG"

Write-Host "Starting Docker Build Stage 2: OpenSCAD Image..."
docker build . `
    -f Dockerfile `
    -t $DOCKER_TAG_OPENSCAD `
    --build-arg "CMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE" `
    --build-arg "DOCKER_TAG_BASE=$DOCKER_TAG_BASE" `
    --build-arg "EMSCRIPTEN_FLAGS=$EMSCRIPTEN_FLAGS" `
    --build-arg "CMAKE_BUILD_PARALLEL_LEVEL=$env:NUMBER_OF_PROCESSORS"

Write-Host "Extracting WASM artifacts..."
mkdir -p build
docker rm -f tmpcpy 2>$null
docker create --name tmpcpy $DOCKER_TAG_OPENSCAD
docker cp tmpcpy:/home/build/openscad.js build/openscad.wasm.js
docker cp tmpcpy:/home/build/openscad.wasm build/
docker rm tmpcpy

Write-Host "Build complete! Artifacts are in the 'build' directory."
