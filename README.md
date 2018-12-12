virtual-desktops.el
===================

Provides virtual desktops in emacs

Allows you to save/retore a frame configuration: windows and buffers.


Keys and interactive functions:  
virtual-desktops-add:             save current configuration in a new virtual desktop and select it (C-c C-d a)  
virtual-desktops-delete:          delete current desktop and select the nil desktop (C-c C-d d)  
virtual-desktops-delete-specific: delete a specific desktop and select the nil desktop if you choose current desktop (C-c C-d D)  
virtual-desktops-goto:            restore a specific desktop (C-c C-d g)  
virtual-desktops-next:            go to next desktop (C->)  
virtual-desktops-previous:        go to previous desktop (C-<)  
virtual-desktops-list:            list all desktops (C-c C-d l)  
virtual-desktops-update:          save current configuration in current desktop  


Variables:  
virtual-desktops-auto-update: if non nil, current desktop will be updated before execution of virtual-desktops-next, virtual-desktops-prev, virtual-desktops-goto
