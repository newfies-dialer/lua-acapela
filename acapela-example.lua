--
-- Usage Example
--

Acapela = require "acapela"
require "acapela_config"

-- print(Acapela)

if ACCOUNT_LOGIN == nil then
    ACCOUNT_LOGIN = 'LOGIN'
    APPLICATION_LOGIN = 'applogin'
    APPLICATION_PASSWORD = 'password'
    SERVICE_URL = 'http://vaas.acapela-group.com/Services/Synthesizer'
    quality = '22k'
    gender = 'W'
    intonation = 'NORMAL'
end

DIRECTORY = '/tmp/'
text = 'Please say this text via Acapela'
language = 'EN'


tts_acapela = Acapela:new{
    ACCOUNT_LOGIN=ACCOUNT_LOGIN,
    APPLICATION_LOGIN=APPLICATION_LOGIN,
    APPLICATION_PASSWORD=APPLICATION_PASSWORD,
    SERVICE_URL=SERVICE_URL,
    QUALITY=QUALITY,
    DIRECTORY=DIRECTORY}

tts_acapela:set_cache(false)
tts_acapela:prepare(text, language, ACAPELA_GENDER, ACAPELA_INTONATION)
output_filename = tts_acapela:run()

print('')
print('Recorded TTS : '..tostring(output_filename))
print('')

-- Test Wget
-- wget('http://cdn.newfies-dialer.org.s3.amazonaws.com/wp-content/uploads/2013/03/call-transfer-do_not_call_list.png', '/tmp/test.png')
