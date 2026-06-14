$SHADERS_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# slangc "$SHADERS_DIR/shaders.slang" -entry vertexMain -stage vertex -target spirv -o "$SHADERS_DIR/spirv/vertex.spv"
# slangc "$SHADERS_DIR/shaders.slang" -entry fragmentMain -stage fragment -target spirv -o "$SHADERS_DIR/spirv/fragment.spv"
slangc "$SHADERS_DIR/shaders.slang" -entry computeMain -stage compute -target spirv -o "$SHADERS_DIR/spirv/compute.spv"
# slangc "$SHADERS_DIR/shaders.slang" -entry vertexMain -stage vertex -target metal -o "$SHADERS_DIR/metal/vertex.metal"
# slangc "$SHADERS_DIR/shaders.slang" -entry fragmentMain -stage fragment -target metal -o "$SHADERS_DIR/metal/fragment.metal"
slangc "$SHADERS_DIR/shaders.slang" -entry computeMain -stage compute -target metal -o "$SHADERS_DIR/metal/compute.metal"
