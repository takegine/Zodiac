```json
{
    "paneltype": "Button",
    "rememberchildfocus": false,
    "style": {},
    "actualuiscale_x": 0.614814817905426,
    "actualuiscale_y": 0.614814817905426,
    "scrolloffset_x": 0,
    "scrolloffset_y": 0,
    "actualyoffset": 0,
    "actualxoffset": 0,
    "actuallayoutheight": 25,
    "actuallayoutwidth": 79,
    "desiredlayoutheight": 25,
    "desiredlayoutwidth": 79,
    "contentheight": 24,
    "contentwidth": 0,
    "layoutfile": "panorama\\layout\\custom_game\\panel_population.xml",
    "id": "PopExample",
    "selectionpos_y": null,
    "selectionpos_x": null,
    "tabindex": null,
    "hittestchildren": true,
    "hittest": true,
    "inputnamespace": "",
    "defaultfocus": "",
    "checked": false,
    "enabled": true,
    "visible": true
}
```

```js
 $("#PopExample").SetPanelEvent('onmouseover',() => { 
                $.DispatchEvent( 'UIShowTextTooltip', $("#PopExample"), 
                $.Localize('Population_Sale').replace(/%\w\d*/,data.popMax)
                );
            }  ) ;

            
$.RegisterEventHandler( "UIShowTextTooltip", $.GetContextPanel(),(par1,par2,par3)=>{
    $.Msg(par1,"\n",par2,"\n",par3)
    par2.replace(/%\w\d*/,999)
})
```