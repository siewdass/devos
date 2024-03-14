#!/usr/bin/env bash

. config.sh

CURRENT_DIR="$(pwd)"

rm -rf $NAME-desktop.deb

mkdir -p /tmp/meta/DEBIAN /tmp/meta/usr/share/glib-2.0/schemas /tmp/meta/usr/share/gtksourceview-4/styles

EXTENSIONS="["
cd ${CURRENT_DIR}/extensions &&
for filename in *; do
  if [ "$EXTENSIONS" != "[" ]; then
		EXTENSIONS+=", "
	fi
	EXTENSIONS+="'${filename::-4}'"
done
EXTENSIONS+="]"

echo "Package: $NAME-desktop
Version: 0.01
Architecture: amd64
Maintainer: any <siewdass@gmail.com>
Installed-Size: 13
Depends: $META_PACKAGE
Section: metapackages
Priority: optional
Description: ${NAME^} Meta Package" > /tmp/meta/DEBIAN/control

echo "[org.gnome.desktop.interface]
gtk-theme = '$SYSTEM_THEME'
icon-theme = '$ICON_THEME'
cursor-theme = '$CURSOR_THEME'
font-name = 'Ubuntu 11'

[org.gnome.desktop.default-applications.terminal]
exec='tilix'

[org.gnome.mutter:GNOME-Classic]
dynamic-workspaces=false

[org.gnome.shell]
always-show-log-out=true
disable-extension-version-validation=true
enabled-extensions = [ 'dash-to-panel@jderose9.github.com', 'user-theme@gnome-shell-extensions.gcampax.github.com' ]
favorite-apps = [ 'org.gnome.Nautilus.desktop', 'com.gexperts.Tilix.desktop', 'google-chrome.desktop' ]

[org.gnome.shell.extensions.user-theme]
name = '$SYSTEM_THEME'

[org.gnome.gedit.preferences.editor]
scheme = 'arc-dark'
tabs-size = 4
display-line-numbers = false

[org.gnome.gedit.preferences.ui]
statusbar-visible = false

[org.gnome.desktop.peripherals.touchpad]
click-method = 'areas'
natural-scroll = false

[org.gnome.desktop.peripherals.mouse]
natural-scroll = false

[org.gnome.nautilus.preferences]
default-sort-order = 'type'

[org.gtk.Settings.FileChooser]
sort-directories-first = true

[org.gnome.desktop.wm.preferences]
button-layout = 'appmenu:minimize,maximize,close'" > /tmp/meta/usr/share/glib-2.0/schemas/90_${NAME}-settings.gschema.override

echo '<?xml version="1.0" encoding="UTF-8"?>

<style-scheme name="Arc Dark" id="arc-dark" version="1.0">
    <author>GameTheory</author>
    <description>A fork of Gedit Material Theme by Maksudur Rahman Maateen</description>

    <!-- Global Settings -->
    <style name="text" foreground="#CDD3DE" background="#404552" />
    <style name="selection" foreground="#002B36" background="#657B83"/>
    <style name="cursor" foreground="#CDD3DE" />
    <style name="current-line" background="#383C4A" />
    <style name="line-numbers" foreground="#CDD3DE" background="#383C4A" />
    <style name="right-margin" foreground="#EEE8D5" background="#93A1A1"/>
    <style name="draw-spaces" foreground="#d3d7cf"/>
    <style name="background-pattern" background="#032F3B"/>

    <!-- Bracket Matching -->
    <style name="bracket-match" foreground="#002B36" background="#586E75"/>
    <style name="bracket-mismatch" foreground="#DC322F" background="#586E75"/>

    <!-- Search Matching -->
    <style name="search-match" foreground="#002B36" background="#B58900"/>

    <!-- Bookmarks -->
    <style name="bookmark" background="#E5E5FF"/>

    <!-- Comments -->
    <style name="def:comment" foreground="#546E7A" italic="true" />
    <style name="def:shebang" foreground="#546E7A" italic="true" />
    <style name="def:doc-comment" foreground="#0000FF"/>
    <style name="def:doc-comment-element" foreground="#546E7A" bold="true" />

    <!-- Constants -->
    <style name="def:constant" foreground="#ffeb95" />
    <style name="def:decimal" foreground="brown"/>
    <style name="def:base-n-integer" foreground="brown"/>
    <style name="def:floating-point"  foreground="#A5C261" />
    <style name="def:complex" use-style="def:base-n-integer"/>
    <style name="def:character" foreground="#FF80E0"/>
    <style name="def:string" foreground="#c3e88d" />
    <style name="def:special-char" foreground="#CDD3DE" />
    <style name="def:builtin" foreground="#6699CC" bold="true" />

    <!-- Identifiers -->
    <style name="def:identifier"  foreground="#F2777A" />
    <style name="def:function" foreground="#82AAFF"/>

    <!-- Statements -->
    <style name="def:statement"   foreground="#EB606B" />

    <!-- Types -->
    <style name="def:type" foreground="#FF5370" />

    <!-- Operators -->
    <style name="def:operator" foreground="#859900"/>

    <!-- Others -->
    <style name="def:preprocessor" foreground="#80CBC41A" />
    <style name="c:preprocessor"  />
    <style name="def:error" foreground="#80CBC41A" bold="true" />
    <style name="def:warning" foreground="brown" underline="true"/>
    <style name="def:note" foreground="#80CBC41A" bold="true" />
    <style name="def:underlined" italic="true" underline="single"/>

    <style name="def:special-constant" foreground="#CDD3DE" bold="true" />
    <style name="def:boolean" foreground="#ffeb95" />
    <style name="def:number"  foreground="#A5C261" />
    <style name="def:keyword" foreground="#C792EA" bold="true" />
    <style name="def:variable"    foreground="#F2777A" />
    <style name="def:net-address-in-comment"  foreground="#F2777A" underline="true" />
    <style name="def:specials"    background="#BB80B3" />
    <style name="diff:ignore" foreground="#80CBC41A" />
    <style name="ruby:module-handler" foreground="#BB80B3" />
    <style name="ruby:symbol" foreground="#ffeb95" />
    <style name="ruby:regex"  foreground="#A5C261" />
    <style name="sh:others"   />
    <style name="xml:attribute-name"  foreground="#C594C5" />
    <style name="xml:element-name"    foreground="#EB606B" />

    <!-- Language specific styles -->
    <style name="c:preprocessor"              foreground="#008000"/>
    <style name="c:included-file"             use-style="c:preprocessor"/>
    <style name="c:common-defines"            foreground="#0095FF" bold="true"/>

    <style name="diff:diff-file"              use-style="def:statement"/>
    <style name="diff:added-line"             use-style="def:decimal"/>
    <style name="diff:removed-line"           use-style="def:string"/>
    <style name="diff:changed-line"           use-style="c:preprocessor"/>
    <style name="diff:special-case"/>
    <style name="diff:location"               use-style="def:type"/>

    <style name="xml:attribute-name"          foreground="#008000"/>
    <style name="xml:element-name"            bold="true"/>
    <style name="xml:entity"                  foreground="#0000FF"/>
    <style name="xml:cdata-delim"             foreground="#008080" bold="true"/>
    <style name="xml:processing-instruction"  bold="true"/>
    <style name="xml:doctype"                 foreground="#800000" bold="true"/>

    <style name="docbook-element"             foreground="#004141" bold="true"/>
    <style name="docbook:header-elements"     use-style="docbook-element"/>
    <style name="docbook:formatting-elements" use-style="docbook-element"/>
    <style name="docbook:gui-elements"        use-style="docbook-element"/>
    <style name="docbook:structural-elements" use-style="docbook-element"/>

    <style name="js:object"                   foreground="#008000"/>
    <style name="js:constructors"             bold="true"/>

    <style name="mooscript:special-vars"      use-style="c:preprocessor"/>

    <style name="latex:display-math"          background="#C0FFC0"/>
    <style name="latex:inline-math"           foreground="#006400"/>
    <style name="latex:math-bound"            bold="true"/>
    <style name="latex:common-commands"       foreground="#800000"/>
    <style name="latex:command"               foreground="#7000DF"/>
    <style name="latex:include"               use-style="latex:common-commands"/>

    <style name="changelog:date"              use-style="def:type"/>
    <style name="changelog:email"             use-style="c:preprocessor"/>
    <style name="changelog:file"              use-style="def:function"/>
    <style name="changelog:bullet"            use-style="changelog:file"/>
    <style name="changelog:release"           foreground="#0095FF" bold="true"/>

    <style name="perl:pod"                    foreground="grey"/>

    <style name="python:string-conversion"    background="#BEBEBE"/>
    <style name="python:module-handler"       use-style="def:character"/>
    <style name="python:special-variable"     use-style="def:type"/>
    <style name="python:builtin-constant"     use-style="def:type"/>
    <style name="python:builtin-object"       use-style="def:type"/>
    <style name="python:builtin-function"     use-style="def:type"/>
    <style name="python:boolean"              use-style="def:type"/>

    <style name="scheme:parens"               use-style="def:statement"/>
    <style name="scheme:any-function"         use-style="def:statement"/>

    <style name="sh:dollar"                   foreground="#008000" bold="true"/>

    <style name="makefile:trailing-tab"       background="#FFC0CB"/>

    <style name="t2t:italic"                  italic="true"/>
    <style name="t2t:bold"                    bold="true"/>
    <style name="t2t:verbatim"                background="#lightgrey"/>
    <style name="t2t:verbatim-block"          line-background="#lightgrey"/>
    <style name="t2t:comment"                 foreground="#008000"/>
    <style name="t2t:option"                  foreground="#008000"/>
</style-scheme>' > /tmp/meta/usr/share/gtksourceview-4/styles/Arc-Dark.xml

dpkg-deb -Z xz -b /tmp/meta ${CURRENT_DIR}/packages/$NAME-desktop.deb > /dev/null

rm -rf /tmp/meta

echo ${CURRENT_DIR}/packages/$NAME-desktop.deb
