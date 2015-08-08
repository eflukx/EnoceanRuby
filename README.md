# EnoceanRuby
[![Code Climate](https://codeclimate.com/github/eflukx/EnoceanRuby/badges/gpa.svg)](https://codeclimate.com/github/eflukx/EnoceanRuby)

EnoceanRuby: a Ruby library for interacting with Enocean radio devices using the _Enocean  Serial Protocol_ ([ESP](https://www.enocean.com/esp)). This is the protocol that the well known TCM310 module (which is also the one on the Raspberry Pi interface) implements.

EnoceanRuby implements an object structure for working with the Enocean protocol. Currently _radio_, _command_ and _event_ packets are supprted. The library van serialise from/to an ESP byte stream. 

This fork's focus was mainly to fully support the A5-20-01 [equipment profile](https://www.enocean.com/fileadmin/redaktion/enocean_alliance/pdf/EnOcean_Equipment_Profiles_EEP_V2.6.3_public.pdf). Please feel free to send PR's adopting other equipment profiles or enhancements/fixes in any other way.
