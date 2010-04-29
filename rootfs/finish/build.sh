# Copyright 2010 Marius Groleo <groleo@gmail.com> <http://groleo.wordpress.com>
# Licensed under the GPL v2. See COPYING in the root of this package.


# This step is called once all components were built, to remove
# un-wanted files, to add tuple aliases
do_finish() {
    CT_DoStep INFO "Cleaning-up the toolchain's directory"


    CT_EndStep
}
