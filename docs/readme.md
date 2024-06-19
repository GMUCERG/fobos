# Instructions for compiling the documentation

## Install on basic Ubuntu 22.04
```
sudo apt-get install python3-pip
sudo pip3 install sphinx
sudo pip3 install sphinx_rtd_theme
sudo pip3 install sphinxcontrib-bibtex
```

## Re-Generate API Documentation Setup
`sphinx-apidoc -f --ext-autodoc -o source/api/ctrl/ ../software/foboslib/ctrl/`

This needs work

## Compile PDF Version
`make latexpdf`

## Compile HTML Version
`make html`

