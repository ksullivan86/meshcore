# MeshCore builds

Hardware I've designed for [MeshCore](https://meshcore.co.uk) mesh radios. Each project comes with everything you need to build it: files to print, pictures of every version, a parts list and a step-by-step guide.

## Projects

<table>
<tr>
<td width="240"><a href="tahoe-repeater/"><img src="tahoe-repeater/images/hero-A.png" width="220" alt="The Tahoe solar repeater mounted on a tree"></a></td>
<td valign="top">
<h3><a href="tahoe-repeater/">Tahoe solar repeater</a></h3>
A repeater that lives on a tree: a RAK4631 radio, a 15 Ah LiFePO4 cell and a small 5 V solar panel in a 3D-printed enclosure that closes with a quarter turn and locks without tools. Built for snow and fire season at Lake Tahoe. Three enclosure versions and three ways to mount the panel, with tree screws, straps or both. The electronics come out on a tool-less sled.
<br><br>
<b>Status:</b> ready to build (design revision 9).
</td>
</tr>
</table>

### Planned

- **Dog-collar tracker.** A small MeshCore GPS tracker that attaches to a dog's collar.
- **Wio Tracker L1 Pro version.** A pogo-pin version built around Seeed's Wio Tracker L1 Pro.

These don't have folders yet. They'll get one when there's something to print.

## How the repo is laid out

Every project has its own folder, set up the same way:

```
project-name/
  README.md   pictures, which file to print and what's different about each
  stl/        one file per version, holding every printed part it needs
  images/     the pictures the docs use
  docs/       parts list (and parts.csv), build guide, notes on changing the design
  cad/        the source files
```

Apart from the link back to this page and to the license, links inside a project stay inside its folder, so you can copy one project out on its own.

## License

Everything here is [CC BY-NC-SA 4.0](LICENSE) unless a project says otherwise. You're welcome to build it, change it and share it for non-commercial use, as long as you give credit and share your changes under the same license. Selling prints, kits or finished units, or using a design in a paid product or service, needs my written permission first. Open an issue to ask.
