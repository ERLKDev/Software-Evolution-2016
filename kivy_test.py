from kivy.app import App
from kivy.lang import Builder
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.scatter import ScatterPlane
from kivy.uix.label import Label
from kivy.uix.widget import Widget
from kivy.uix.button import Button
from kivy.uix.scrollview import ScrollView
from kivy.uix.gridlayout import GridLayout
from kivy.graphics.instructions import InstructionGroup
from kivy.graphics import Color, Rectangle
from kivy.core.window import Window
from kivy.uix.relativelayout import RelativeLayout
from kivy.uix.popup import Popup

import matplotlib.cm as cmx
import matplotlib.colors as colors


from kivy.uix.codeinput import CodeInput
from pygments.lexers import CythonLexer

from visualize_duplicates import *

class MenuScreen(Screen):
    def __init__ (self, **kwargs):
        super (MenuScreen, self).__init__(**kwargs)

        self.duplist = duplist

        layout = GridLayout(cols=1, padding=10, spacing=10,
                size_hint=(None, None), width=750)

        layout.bind(minimum_height=layout.setter('height'))

        files = reversed(sorted(dupfiles, key=dupfiles.get))
        for dupfile in files:
            btn = Button(text="%s :  %d" %(dupfile, dupfiles[dupfile]), size=(750, 40),
                         size_hint=(None, None))
            btn.bind(on_release=self.openDocView(dupfile))
            layout.add_widget(btn)


        root = ScrollView(size_hint=(None, None), size=(750, 600),
                pos_hint={'center_x': .5, 'center_y': .5}, do_scroll_x=False)
        root.add_widget(layout)

        self.add_widget(root)

    def openDocView(self, path):
        def openView(obj):
            dupClasses = []
            dupFiles = {}
            print path
            for x in self.duplist:
                keys = x.getDups().keys()
                if path in keys:
                    dupClasses.append(x)
                    for y in keys:
                        if y not in dupFiles.keys():
                            with open(y) as f:
                                dupFiles[y] = len(f.readlines())

            sm.add_widget(DocView(name='docView', file_name=path, dupClasses=dupClasses, dupFiles=dupFiles))
            sm.current = 'docView'
        return openView


class DocView(Screen):
    def __init__ (self, file_name, dupClasses, dupFiles, **kwargs):
        super (DocView, self).__init__(**kwargs)

        #print dupFiles
        self.height_constant = 5.0
        self.sf = 1.0
        self.size = Window.size
        self.file_name = file_name

        parent = Widget()

        screen_size = self.size

        if len(dupFiles) * 220 + 200 > screen_size[0]:
            self.sf = (len(dupFiles) * 220 + 200) / float(screen_size[0])

        max_height = dupFiles[max(dupFiles, key=dupFiles.get)] * self.height_constant *1.4

        if max_height > screen_size[1] and self.sf < max_height / float(screen_size[1]):
            self.sf = max_height / float(screen_size[1])

        s = ScatterPlane(scale=1/self.sf, do_scale=True, do_rotation=False)
        parent.add_widget(s)


        clearbtn = Button(text='Back')
        clearbtn.bind(on_release=self.back)
        parent.add_widget(clearbtn)

        index = 0
        max_height = 0
        for x in dupFiles:
            self.addBlock(s, dupFiles[x], dupClasses, x, index)
            if dupFiles[x] * self.height_constant > max_height:
                max_height = dupFiles[x] * self.height_constant

            index += 1

        self.add_widget(parent)

    def addBlock(self, view, loc, dupsClasses, path, index):
        height = loc * self.height_constant

        norm  = colors.Normalize(vmin=0, vmax=len(dupsClasses))
        color_map = cmx.ScalarMappable(norm=norm, cmap='hsv')

        layout = RelativeLayout(size=(200, height + 20), pos=(0 + (220 * index), ((self.size[1] / 2.0) * self.sf - (height / 2.0))))
        with layout.canvas:
            Color(1., 1., 1.)
            Rectangle(pos=(0, 0), size=(200, height + 20))


        l = Label(text=path.split("/")[-1], font_size='10sp', color=(0, 0, 0, 1), pos=(0,(height/2.0) + 5))

        layout.add_widget(l)

        i = 0
        for dupClass in dupsClasses:
            if path in dupClass.getDups():
                duplicates = dupClass.getDups()[path]
                rgba = color_map.to_rgba(i)
                for dup in duplicates:
                    start, end = dup.getLoc()

                    dupLoc = (end - start + 1) * self.height_constant

                    dup_height = (dupLoc) / float(height + 20)

                    dup_pos = ((height) - (start * self.height_constant)) - dupLoc
                    button = Button(text="%d-%d:%d" % (start, end, end - start + 1), size_hint=(1.0, dup_height), pos=(0, dup_pos), background_color=rgba)
                    button.bind(on_release= self.dupClicked(path, start, end))
                    layout.add_widget(button)
            i += 1

        # Here, view should be a Widget or subclass
        view.add_widget(layout)


    def dupClicked(self, path, start, end):
        layout = RelativeLayout()
        code = ""
        fo = open(path, "r")
        lines = fo.readlines()

        for x in range(end-start + 1):
            code += lines[start + x -1]

        codeinput = CodeInput(lexer=CythonLexer(), text=code, readonly=False)
        button = Button(text="Close", size_hint=(0.3, 0.05), pos_hint={'right' : 1})


        layout.add_widget(codeinput)
        layout.add_widget(button)

        popup = Popup(content=layout, auto_dismiss=False, title="Path: %s\nStart: %d, end: %d, size: %d"%(path, start, end, end - start + 1))
        button.bind(on_press=popup.dismiss)

        def openPopup(obj):
            popup.open()

        return openPopup

    def back(self, obj):
        sm.current = 'menu'
        sm.remove_widget(sm.get_screen('docView'))


# Create the screen manager
sm = ScreenManager()
dupfiles, duplist = convertRascalToDups('TestProject/blader.tmp')
sm.add_widget(MenuScreen(name='menu', dupfiles=dupfiles, duplist=duplist))

class TestApp(App):

    def build(self):
        return sm

if __name__ == '__main__':
    TestApp().run()
