# file: Makefile.tpl		G. Moody	 24 May 2000
#				Last revised:	24 June 2002
# Change the settings below as appropriate for your setup.

# D2PARGS is a list of options for dvips.  Uncomment one of these to set the
# paper size ("a4" is most common except in the US and Canada):
# D2PARGS = -t a4
D2PARGS = -t letter

# T2DARGS is a list of options for texi2dvi.  Uncomment one of these to set the
# page size (the size of the printed area on the paper;  normally this should
# match the paper size specified in D2PARGS):
# T2DARGS = -t @afourpaper
T2DARGS = -t @letterpaper

# LN is a command that makes the file named by its first argument accessible
# via the name given in its second argument.  If your system supports symbolic
# links, uncomment the next line.
LN = ln -sf
# Otherwise uncomment the next line if your system supports hard links.
# LN = ln
# If your system doesn't support links at all, copy files instead.
# LN = cp

# If you wish to install the info (GNU hypertext documentation) files from this
# package, specify the command needed to format them from the texinfo source
# files.  If you have the GNU 'makeinfo' utility (the preferred formatter),
# uncomment the next line.
MAKEINFO = makeinfo --force --no-warn
# Otherwise, you can use GNU emacs to do the job by uncommenting the next line.
# MAKEINFO = ./makeinfo.sh

# PERL is the full pathname of your perl interpreter, needed for 'make htmlpg'.
PERL = /usr/bin/perl

# PSPRINT is the name of the program that prints PostScript files. If your
# printer is not a PostScript printer, see the GhostScript documentation to see
# how to do this (since the figure files are in PostScript form, it is not
# sufficient to use a non-PostScript dvi translator such as dvilj).
PSPRINT = lpr

# TROFF is the name of the program that prints UNIX troff files (needed to
# print the covers of the guide).  Use 'groff' if you have
# GNU groff (the preferred formatter).
TROFF = groff
# Use 'ptroff' if you have Adobe TranScript software.
# TROFF = ptroff
# Consult your system administrator if you have neither 'groff' nor 'ptroff'.
# Other (untested) possibilities are 'psroff', 'ditroff', 'nroff', and 'troff'.

# It should not be necessary to modify anything below this line.
# -----------------------------------------------------------------------------

.IGNORE:

all:	wpg.html wpg.ps wpg.pdf
	$(MAKE) INFODIR=../wpg/info wpg.info
	rm -f ../wpg/info/dir
	cp -p wpg.ps wpg.pdf ../wpg

install:
	@echo Nothing to install in wpg-src.

uninstall:
	rm -f ../wpg/*

# 'make wpg-book': print a copy of the WFDB Programmer's Guide
wpg-book:	wpg.ps
	$(TROFF) wpg.cover >wpgcover.ps
	$(PSPRINT) wpgcover.ps wpg.ps

# 'make wpg.hlp': format the WFDB Programmer's Guide as an MS-Windows help file
wpg.hlp:	wpg.tex
	makertf --hpj=wpg.hpj --output=wpg.rtf --force wpg.tex
	@echo Ignore any errors that appear above!
	hcrtf -o wpg.hlp -x wpg.hpj
	test -s WPG.HLP && mv WPG.HLP wpg.hlp
	rm -f wpg.rtf wpg.hpj wpg.ph

# 'make wpg.html': format the WFDB Programmer's Guide as HTML
wpg.html:
	cp -p wpg.tex ../wpg
	cd ../wpg; texi2html -short_ext -menu -split_node wpg.tex
	mv ../wpg/wpg.htm ../wpg/wpg_btoc.htm	# use top page as brief TOC
	cp wpg.ht0 ../wpg/wpg.htm
	rm -f ../wpg/wpg.tex
	./fixpg.sh ../wpg
	date '+%e %B %Y' >>../wpg/wpg.htm
	cat ../misc/foot.ht0 >>../wpg/wpg.htm
	cd ../wpg; $(LN) wpg.htm index.html

# 'make wpg.info': format the WFDB Programmer's Guide as info files
wpg.info:	$(INFODIR)
	test -d $(INFODIR) || \
	 ( mkdir -p $(INFODIR); $(SETDPERMISSIONS $(INFODIR) )
	$(MAKEINFO) wpg.tex
	test -s wpg && \
         cp wpg wpg-* $(INFODIR); \
         ( test -s $(INFODIR)/wpg && \
	  ( $(SETPERMISSIONS) $(INFODIR)/wpg*; \
	   ( test -s $(INFODIR)/dir || cp dir.top $(INFODIR)/dir ); \
	   ( grep -s wpg $(INFODIR)/dir >/dev/null || \
	     cat dir.wpg >>$(INFODIR)/dir ))); \
	rm -f wpg wpg-*

# 'make wpg.info.tar.gz': create a tarball of info files
wpg.info.tar.gz:
	$(MAKEINFO) wpg.tex
	mv wpg wpg-* info
	tar cfv - info | gzip >info.tar.gz

# 'make wpg.pdf': format the WFDB Programmer's Guide as PDF
wpg.pdf:	wpg.tex
	rm -f wpg.aux wpg.idx wpg.ind wpg.toc
	texi2dvi --pdf $(T2DARGS) wpg.tex

# 'make pg.ps': format the WFDB Programmer's Guide as PostScript
wpg.ps:		wpg.tex
	rm -f wpg.aux wpg.idx wpg.ind wpg.toc
	texi2dvi $(T2DARGS) wpg.tex
	dvips $(D2PARGS) -o wpg.ps wpg.dvi

# 'make clean': remove intermediate and backup files
clean:
	rm -f info.tar.gz info/wpg* wpg.aux wpg.cp wpg.cps wpg.dvi wpg.fn \
	 wpg.fns wpg.ky wpg.log wpg.pdf wpg.ps wpg.pg wpg.toc wpg.tp wpg.vr \
	 wpgcover.ps *~ ../wpg/info/dir
