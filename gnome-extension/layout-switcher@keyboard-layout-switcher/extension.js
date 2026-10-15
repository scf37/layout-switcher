// Exposes GNOME Shell's input source manager on the session bus, so layout can be
// switched without synthesizing key presses:
//
//   gdbus call --session --dest org.gnome.Shell \
//     --object-path /org/gnome/Shell/Extensions/LayoutSwitcher \
//     --method org.gnome.Shell.Extensions.LayoutSwitcher.Next

import Gio from 'gi://Gio';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Keyboard from 'resource:///org/gnome/shell/ui/status/keyboard.js';

const IFACE = `
<node>
  <interface name="org.gnome.Shell.Extensions.LayoutSwitcher">
    <method name="Next">
      <arg type="u" name="index" direction="out"/>
    </method>
    <method name="Activate">
      <arg type="u" name="index" direction="in"/>
    </method>
    <method name="List">
      <arg type="as" name="ids" direction="out"/>
    </method>
    <property name="Current" type="u" access="read"/>
  </interface>
</node>`;

class LayoutSwitcherService {
    get _manager() {
        return Keyboard.getInputSourceManager();
    }

    get _sources() {
        const sources = this._manager.inputSources;
        return Object.keys(sources).map(k => sources[k]).sort((a, b) => a.index - b.index);
    }

    get Current() {
        return this._manager.currentSource?.index ?? 0;
    }

    Next() {
        const sources = this._sources;
        if (sources.length === 0)
            return 0;
        const next = (this.Current + 1) % sources.length;
        sources[next].activate(true);
        return next;
    }

    Activate(index) {
        const source = this._sources[index];
        if (!source)
            throw new Error(`no input source with index ${index}`);
        source.activate(true);
    }

    List() {
        return this._sources.map(s => s.id);
    }
}

export default class LayoutSwitcherExtension extends Extension {
    enable() {
        this._dbus = Gio.DBusExportedObject.wrapJSObject(IFACE, new LayoutSwitcherService());
        this._dbus.export(Gio.DBus.session, '/org/gnome/Shell/Extensions/LayoutSwitcher');
    }

    disable() {
        this._dbus?.unexport();
        this._dbus = null;
    }
}
