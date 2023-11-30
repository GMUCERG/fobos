# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
import sys
sys.path.insert(0, os.path.abspath('../../software/foboslib/ctrl/'))
autodoc_mock_imports = ["serial","foboslib","time","socket","pickle","numpy","sys"]
autodoc_typehints = 'description'
typehints_defaults = 'comma'

# -- Project information -----------------------------------------------------

project = 'FOBOS User Guide'
copyright = '2023, Cryptographic Engineering Research Group (CERG)'
author = 'Abubakr Abdulgadir, Luke Beckwith, Eduardo Ferrufino, and Jens-Peter Kaps'

# The full version, including alpha/beta/rc tags
release = '3.0'
version = '3.0'


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'sphinx.ext.todo',
    'sphinx.ext.githubpages',
    'sphinx.ext.autodoc',
    'sphinx.ext.coverage', 
    'sphinx.ext.napoleon'
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

source_suffix = '.rst'

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

pygments_style = 'sphinx'

# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
# html_theme = 'alabaster'
html_theme = 'sphinx_rtd_theme'
#html_short_title = 'FOBOS User Guide'
#html_title = 'FOBOS User Guide'
html_show_sourcelink = False

#
#import cakephp_theme
#html_theme_path = [cakephp_theme.get_html_theme_path()]
#html_theme = 'cakephp_theme'
#extensions = ['cakephp_theme']
#
#html_context = {
#    'maintainer': 'Your Name',
#    'project_pretty_name': 'Your Project Name',
#    'projects': {
#        'CakePHP Book': 'https://book.cakephp.org/',
#        'Some other project': 'https://example.com/',
#    }
#}

html_sidebars = {
    '**': ['globaltoc.html', 'localtoc.html']
}
# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
master_doc = 'index'
html_static_path = ['_static']
html_css_files = [
    'css/cergdoc.css',
]
#html_logo = 'cergimg/CERG-logo-only80.png'

# -- Options for LaTeX output -------------------------------------------------
latex_elements = {
    'preamble': r'\usepackage{cergdoc}',
    'maketitle': r'''\topicpic{fobos-slide}
        \subtitle{FOBOS v3.0, User Guide}
        \cergmaketitle{}''',
}
latex_additional_files = ["cergdoc.sty",
    "./cergimg/cerg.png",
    "./cergimg/Mason.pdf",
    "./cergimg/fobos-slide.jpg"]

latex_documents = [
    (master_doc, 'fobos3_user-guide.tex',
        'Flexible, Opensource workBench fOr Side-channel analysis (FOBOS)',
        'Abubakr Abdulgadir \\and Luke Beckwith \\and Eduardo Ferrufino \\and Jens-Peter Kaps',
        'manual',True),
]

numfig = True
