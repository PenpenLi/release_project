local shaders = {}


function getShaderStateByName(name)
	local gl_state = cc.GLProgramState:create(cc.GLProgram:createWithFilenames('shaders/ccShader_PositionTextureColor_noMVP.vert','shaders/ccFilterShader_saturation.frag'))
	gl_state:setUniformFloat('u_saturation', 0.1)
	sp:setGLProgramState(gl_state)
end

--变灰
function SpriteSetGray(sprite,num)

	local gl_state = cc.GLProgramState:create(cc.GLProgram:createWithFilenames('shaders/ccShader_PositionTextureColor_noMVP.vert','shaders/ccFilterShader_saturation.frag'))
	gl_state:setUniformFloat('u_saturation', num)
	sprite:setGLProgramState(gl_state)
end