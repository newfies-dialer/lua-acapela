===========
lua-acapela
===========

:Author: Arezqui Belaid
:Description: Lua wrapper for text-to-speech synthesis with Acapela
:Company: Developed by Star2Billing http://www.star2billing.com
:License: MIT


Lua Acapela Wrapper
===================

lua-acapela is a library to produce a text-to-speech file using `Acapela`_ web services.

.. _Acapela: http://acapela-vaas.com/


Quickstart
==========

::

    require "acapela"

    ACCOUNT_LOGIN = 'EVAL_XXXX'
    APPLICATION_LOGIN = 'EVAL_XXXXXXX'
    APPLICATION_PASSWORD = 'XXXXXXXX'
    SERVICE_URL = 'http://vaas.acapela-group.com/Services/Synthesizer'

    tts_acapela = Acapela(ACCOUNT_LOGIN, APPLICATION_LOGIN, APPLICATION_PASSWORD, SERVICE_URL, QUALITY, directory)

    TEXT="Hola! Buenos días"
    LANG = 'ES'
    ACAPELA_GENDER = 'W'
    ACAPELA_INTONATION = 'NORMAL'
    tts_acapela:prepare(TEXT, LANG, ACAPELA_GENDER, ACAPELA_INTONATION)
    output_filename = tts_acapela:run()

    print("Recorded TTS = "..output_filename)


Features
--------

* Produce text to speech in different languages, see list of languages supported :
  http://www.acapela-vaas.com/ReleasedDocumentation/voices_list.php

* Support different type of audio quality 22Hz, 8Hz

* Provide voices of different gender and intonation


Feedback
--------

Write email to areski@gmail.com or post bugs and feature requests on github:

http://github.com/areski/lua-acapela/issues


Extra information
-----------------

Newfies-Dialer, an Open Source Voice BroadCasting Solution, uses this module to synthetize audio files being play to the end-user.
Further information about Newfies-Dialer can be found at http://www.newfies-dialer.org

This module is built and supported by Star2Billing : http://www.star2billing.com

Similar library in Python : http://github.com/areski/python-acapela

Similar library in Ruby : https://github.com/mheld/acapela-ruby


Source download
---------------

The source code is currently available on github. Fork away!

http://github.com/areski/lua-acapela
