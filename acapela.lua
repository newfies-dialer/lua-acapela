--
-- acapela.lua - Lua wrapper for text-to-speech synthesis with Acapela
-- Copyright (C) 2012 Arezqui Belaid <areski@gmail.com>
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation files
-- (the "Software"), to deal in the Software without restriction,
-- including without limitation the rights to use, copy, modify, merge,
-- publish, distribute, sublicense, and/or sell copies of the Software,
-- and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
-- BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
-- ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

lua_acapela_version = '0.1.0'

ACCOUNT_LOGIN = 'EVAL_XXXX'
APPLICATION_LOGIN = 'EVAL_XXXXXXX'
APPLICATION_PASSWORD = 'XXXXXXXX'

SERVICE_URL = 'http://vaas.acapela-group.com/Services/Synthesizer'
LANGUAGE = 'EN'
QUALITY = '22k'  -- 22k, 8k, 8ka, 8kmu
DIRECTORY = '/tmp/'


class Acapela(object):
    -- Properties
    TTS_ENGINE = nil
    ACCOUNT_LOGIN = nil
    APPLICATION_LOGIN = nil
    APPLICATION_PASSWORD = nil
    SERVICE_URL = nil
    QUALITY = nil
    DIRECTORY = ''
    filename = nil
    cache = true
    data = {}

    -- Available voices list
    -- http://www.acapela-vaas.com/ReleasedDocumentation/voices_list.php
    langs = {
        'EN': {'W': {'NORMAL': 'rachel'}, 'M': {'NORMAL': 'margaux'}},
        'US': {'W': {'NORMAL': 'heather'}, 'M': {'NORMAL': 'ryan'}},
        'ES': {'W': {'NORMAL': 'ines'}, 'M': {'NORMAL': 'antonio'}},
        'FR': {'W': {'NORMAL': 'alice'}, 'M': {'NORMAL': 'antoine'}},
        'PT': {'W': {'NORMAL': 'celia'}},
        'BR': {'W': {'NORMAL': 'marcia'}},
        }

    function init(self, account_login, application_login, application_password, service_url, quality, directory='')
        -- Construct Acapela TTS
        self.TTS_ENGINE = 'ACAPELA'
        self.ACCOUNT_LOGIN = account_login
        self.APPLICATION_LOGIN = application_login
        self.APPLICATION_PASSWORD = application_password
        self.SERVICE_URL = service_url
        self.QUALITY = quality
        self.DIRECTORY = directory
    end

    function prepare(self, text, lang, gender, intonation)
        -- Prepare Acapela TTS
        lang = lang.upper()
        concatkey = text..'-'..lang..'-'..gender..'-'..intonation
        key = self.TTS_ENGINE..''..str(hash(concatkey))
        try:
            req_voice = self.langs[lang][gender][intonation]..self.QUALITY
        except:
            req_voice = 'lucy22k'

        self.data = {
            'cl_env': 'PYTHON_2.X',
            'req_snd_id': key,
            'cl_login': self.ACCOUNT_LOGIN,
            'cl_vers': '1-30',
            'req_err_as_id3': 'yes',
            'req_voice': req_voice,
            'cl_app': self.APPLICATION_LOGIN,
            'prot_vers': '2',
            'cl_pwd': self.APPLICATION_PASSWORD,
            'req_asw_type': 'STREAM',
            }
        self.filename = key..'-'..lang..'.mp3'
        self.data['req_text'] = '\\vct=100\\ \\spd=160\\ '..text.encode('utf-8')
    end

    function set_cache(self, value=True)
        -- Enable Cache of file, if files already stored return this filename
        self.cache = value
    end

    function run(self)
        -- run will call acapela API and and produce audio"""

        -- check if file exists
        if self.cache and os.path.isfile(self.DIRECTORY..self.filename) then
            return self.filename
        else
            encdata = parse.urlencode(self.data)
            request.urlretrieve(self.SERVICE_URL, self.DIRECTORY..self.filename, data=encdata)
            return self.filename
        end
    end

--
-- function main
--
function main()
    acclogin = 'LOGIN'
    applogin = 'applogin'
    password = 'password'
    text = 'this is the text'
    language = 'EN'

    quality = QUALITY
    directory = DIRECTORY
    url = SERVICE_URL
    language = LANGUAGE

    tts_acapela = Acapela(acclogin, applogin, password, url, quality, directory)
    gender = 'W'
    intonation = 'NORMAL'
    tts_acapela.set_cache(False)
    tts_acapela.prepare(text, language, gender, intonation)
    output_filename = tts_acapela.run()

    print('Recorded TTS to '..directory..output_filename)

--
-- Test
--
if false then
    -- run function
    main()
end
