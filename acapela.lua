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


local oo = require "loop.simple"
local inspect = require 'inspect'
require "md5"
require "lfs"
require "curl"


lua_acapela_version = '0.1.0'


-- Check file exists and readable
function file_exists(path)
    local attr = lfs.attributes(path)
    if (attr ~= nil) then
        return true
    else
        return false
    end
end

--
-- Get an url and save result to file
--
function wget(url, outputfile)
    -- open output file
    f = io.open(outputfile, "w")

    local text = {}
    local function writecallback(str)
        f:write(str)
        return string.len(str)
    end
    local c = curl.easy_init()
    c:setopt(curl.OPT_URL, url)
    c:setopt(curl.OPT_WRITEFUNCTION, writecallback)
    c:setopt(curl.OPT_USERAGENT, "luacurl-agent/1.0")
    c:perform()

    -- close output file
    f:close()
    return table.concat(text,'')
end

--
-- URL Encoder
--
function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str
end

--
-- Acapela Class
--
Acapela = oo.class{
    -- default field values
    ACCOUNT_LOGIN = 'EVAL_XXXX',
    APPLICATION_LOGIN = 'EVAL_XXXXXXX',
    APPLICATION_PASSWORD = 'XXXXXXXX',

    SERVICE_URL = 'http://vaas.acapela-group.com/Services/Synthesizer',
    LANGUAGE = 'EN',
    QUALITY = '22k',  -- 22k, 8k, 8ka, 8kmu
    DIRECTORY = '/tmp/',

    -- Properties
    TTS_ENGINE = nil,
    filename = nil,
    cache = true,
    data = {},
    langs = {},
}


function Acapela:__init(account_login, application_login, application_password, url, quality, directory)
    -- constructor
    return oo.rawnew(self, {
        TTS_ENGINE = 'ACAPELA',
        ACCOUNT_LOGIN = account_login,
        APPLICATION_LOGIN = application_login,
        APPLICATION_PASSWORD = application_password,
        SERVICE_URL = url,
        QUALITY = quality,
        DIRECTORY = directory or '',
    })
end


function Acapela:prepare(text, lang, gender, intonation)

    -- Available voices list
    -- http://www.acapela-vaas.com/ReleasedDocumentation/voices_list.php

    self.langs = {
        EN = {W = {NORMAL = 'rachel'}, M = {NORMAL = 'margaux'}},
        US = {W = {NORMAL = 'heather'}, M = {NORMAL = 'ryan'}},
        ES = {W = {NORMAL = 'ines'}, M = {NORMAL = 'antonio'}},
        FR = {W = {NORMAL = 'alice'}, M = {NORMAL = 'antoine'}},
        PT = {W = {NORMAL = 'celia'}},
        BR = {W = {NORMAL = 'marcia'}},
    }

    -- Prepare Acapela TTS
    if string.len(text) == 0 then
        return false
    end
    lang = string.upper(lang)
    concatkey = text..'-'..lang..'-'..gender..'-'..intonation
    hash = md5.sumhexa(concatkey)

    key = self.TTS_ENGINE..'_'..hash
    req_voice = self.langs[lang][gender][intonation]..self.QUALITY
    --req_voice = 'lucy22k'
    self.filename = key..'-'..lang..'.mp3'

    self.data = {
        cl_env = 'LUA',
        req_snd_id = key,
        cl_login = self.ACCOUNT_LOGIN,
        cl_vers = '1-30',
        req_err_as_id3 = 'yes',
        req_voice = req_voice,
        cl_app = self.APPLICATION_LOGIN,
        prot_vers = '2',
        cl_pwd = self.APPLICATION_PASSWORD,
        req_asw_type = 'STREAM',
        --req_text = text,
        req_text = '\\vct=100\\ \\spd=160\\ '..text,
        --req_text = 'Hello+how+are+you',
    }
end

function Acapela:set_cache(value)
    -- Enable Cache of file, if files already stored return this filename
    self.cache = value
end

function Acapela:run()
    -- Run will call acapela API and reproduce audio

    -- Check if file exists
    if self.cache and file_exists(self.DIRECTORY..self.filename) then
        return self.filename
    else
        --Get all the Get params and encode them
        get_params = ''
        for k, v in pairs(self.data) do
            if get_params ~= '' then
                get_params = get_params..'&'
            end
            get_params = get_params..tostring(k)..'='..url_encode(v)
        end

        wget(self.SERVICE_URL..'?'..get_params, self.DIRECTORY..self.filename)

        -- Debug
        -- print(self.SERVICE_URL..'?'..get_params)
        -- print(inspect(self.data))

        if file_exists(self.DIRECTORY..self.filename) then
            return self.DIRECTORY..self.filename
        else
            --Error
            return false
        end

    end
end


--
-- Test
--
if false then

    --TODO: add parse init files

    require "acapela_config"

    if ACCOUNT_LOGIN == nil then
        ACCOUNT_LOGIN = 'LOGIN'
        APPLICATION_LOGIN = 'applogin'
        APPLICATION_PASSWORD = 'password'
        SERVICE_URL = 'http://vaas.acapela-group.com/Services/Synthesizer'
        quality = '22k'
        gender = 'W'
        intonation = 'NORMAL'
    end

    directory = '/tmp/'
    text = 'Please say this text via Acapela'
    language = 'EN'


    tts_acapela = Acapela(ACCOUNT_LOGIN, APPLICATION_LOGIN, APPLICATION_PASSWORD, SERVICE_URL, QUALITY, directory)

    tts_acapela:set_cache(false)
    tts_acapela:prepare(text, language, ACAPELA_GENDER, ACAPELA_INTONATION)
    output_filename = tts_acapela:run()

    print('Recorded TTS : '..output_filename)
end
