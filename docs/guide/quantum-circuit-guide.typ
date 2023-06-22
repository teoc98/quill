#import "template.typ": *
#import "../../quantum-circuit.typ": *
#show link: underline

#show: project.with(
  title: "Guide for the Quantum-Circuit Package ",
  authors: ("Mc-Zen",),
  abstract: [Quantum-Circuit is a library for creating quantum circuit diagrams in #link("https://typst.app/", [Typst]). ],
  date: "June 4, 2023",
)

#show link: set text(fill: purple.darken(30%))
#show raw.where(block: true) : set par(justify: false)

#let ref-fn(name) = name // link(label("/quantum-circuit" + name), raw(name))

#let makefigure(code, content, vertical: false) = {
  align(center,
    box(fill: gray.lighten(90%), inset: 1em, {
      table(
        align: center + horizon, 
        columns: if vertical { 1 } else { 2 }, 
        gutter: 1em,
        stroke: none,
        box(code), block(content)
      )
    })
  )
}


#let example-code(filename, fontsize: 1em) = {
  let content = read(filename)
  content = content.slice(content.position("*")+1).trim()
  makefigure(text(size: fontsize, raw(lang: "typ", block: true, content)), [])
  align(center, include(filename))
}

#outline(depth: 1, indent: 2em)



= Introduction

_@gate-gallery features a gallery of many gates that are possible to use with this library and how to create them. In @demo, you can find a variety of example figures along with the code. _

Would you like to create quantum circuits directly in Typst? Maybe a circuit for quantum teleportation?
#align(center)[#include("../../examples/teleportation.typ")]

Or rather for phase estimation (the code for both examples can be found in @demo)?
#align(center)[#include("../../examples/phase-estimation.typ")]

This library provides high-level functionality for generating these and more quantum circuit diagrams. 

For those who work with the LaTeX packages `qcircuit` and `quantikz`, the syntax will be somewhat familiar. The wonderful thing about Typst is that the changes can be viewed instantaneously which makes it ever so much easier to design a beautiful quantum circuit. The syntax also has been updated a little bit to fit with concepts of the Typst language and many things like styling content is much simpler than with `quantikz` since it is directly supported in Typst. 



= Basics

A basic circuit can be created by calling the #ref-fn("quantum-circuit()") command with a number of circuit elements:


// #makefigure(
// ```typ
// #quantum-circuit(
//   lstick($|0〉$), gate($H$), phase($ϑ$), 
//   gate($H$), rstick($cos ϑ/2 lr(|0〉)-sin ϑ/2 lr(|1〉)$)
// )
// ```, quantum-circuit(
//   lstick($|0〉$), gate($H$), phase($ϑ$), gate($H$), rstick($cos ϑ/2 lr(|0〉)-sin ϑ/2 lr(|1〉)$)
// ))


#makefigure(
```typ
#quantum-circuit(
  1, gate($H$), phase($theta.alt$), meter(), 1
)
```, quantum-circuit(
  1, gate($H$), phase($theta.alt$), meter(), 1
))

A quantum gate is created using the #ref-fn("gate()") command. Unlike `qcircuit` and `quantikz`, the math environment is not automatically entered for the content of the gate which allows to pass in any type of content (even images or tables). Use displaystyle math (for example `$ U_1 $` instead of `$U_1$`) to enable appropriate scaling of the gate for more complex mathematical expressions like double subscripts etc. 

Consecutive gates are automatically joined with wires. Plain integers can be used to indicate a number of cells with just wire and no gate (where you would use a lot of `&`'s and `qw`'s in `quantikz`): 

#makefigure(
```typ
#quantum-circuit(
  1, gate($H$), 4, meter()
)
```, quantum-circuit(
  1, gate($H$), 4, meter()
))

#show raw: set text(size: .9em)


A new wire can be created by breaking the current wire with `[\ ]`:
#makefigure(
```typ
#quantum-circuit(
  1, gate($H$), ctrl(1), 1, [\ ],
  2, targ(), 1
)
```, quantum-circuit(
  1, gate($H$), ctrl(1), 1, [\ ],
  2, targ(), 1
))
We can create a #smallcaps("cx")-gate by calling #ref-fn("ctrl(0)") and passing the relative distance to the desired wire, e.g., `1` to the next wire, `2` to the second-next one or `-1` to the previous wire. Per default, the end of the vertical wire is  just joined with the target wire without any decoration at all. Here, we make the gate a #smallcaps("cx")-gate by adding a #ref-fn("targ()") symbol on the second wire. 

Let's look at a quantum bit-flipping error correction circuit. Here we encounter our first multi-qubit gate as well as wire labels:
#makefigure(vertical: true,
```typ
#quantum-circuit(
  lstick($|psi〉$), ctrl(1), ctrl(2), mqgate($E_"bit"$, 3), ctrl(1), ctrl(2), 
    targ(), rstick($|psi〉$), [\ ],
  lstick($|0〉$), targ(), 2, targ(), 1, ctrl(-1), 1, [\ ],
  lstick($|0〉$), 1, targ(), 2, targ(), ctrl(-1), 1
)
```, quantum-circuit(
  scale-factor: 80%,
  lstick($|psi〉$), ctrl(1), ctrl(2), mqgate($E_"bit"$, 3), ctrl(1), ctrl(2), targ(), rstick($|psi〉$), [\ ],
  lstick($|0〉$), targ(), 2, targ(), 1, ctrl(-1), 1, [\ ],
  lstick($|0〉$), 1, targ(), 2, targ(), ctrl(-1), 1
))

Multi-qubit gates have a dedicated command #ref-fn("mqgate()") which takes the content as well as the number of qubits. Wires can be labelled at the beginning or the end with the #ref-fn("lstick()") and #ref-fn("rstick()") commands respectively. 


In many circuits, we need classical wires. This library generalizes the concept of quantumm classical and bundled wires and provides the #ref-fn("setwire()") command that allows all sorts of changes to the current wire setting. You may call `setwire()` with the number of wires to display:

#makefigure(vertical: false,
```typ
#quantum-circuit(
  1, gate($A$), meter(target: 1), [\ ],
  setwire(2), 2, ctrl(0), 2, [\ ],
  1, gate($X$), setwire(0), 1, lstick($|0〉$), 
    setwire(1), gate($Y$),
)
```, quantum-circuit(
  1, gate($A$), meter(target: 1), [\ ],
  setwire(2), 2, ctrl(0), 2, [\ ],
  1, gate($X$), setwire(0), 1, lstick($|0〉$), setwire(1), gate($Y$),
))

The `setwire` command produces no cells and can be called at any point on the wire. When a new wire is started, the default wire setting is restored automatically (quantum wire with default wire style, see @circuit-styling on how to customize the default). Calling `setwire(0)` removes the wire altogether until `setwire` is called with different arguments. More than two wires are possible and it lies in your hands to decide how many wires still look good. The distance between wires can also be specified:

#makefigure(vertical: false,
```typ
#quantum-circuit(
  setwire(4, wire-distance: 1.5pt), 1, gate($U$), meter()
)
```, quantum-circuit(
  setwire(4, wire-distance: 1.5pt), 1, gate($U$), meter()
))



#pagebreak()
= Circuit Styling <circuit-styling>

The #ref-fn("quantum-circuit()") command provides several options for styling the entire circuit. The parameters `row-spacing` and `column-spacing` allow changing the optical density of the circuit by adjusting the spacing between circuit elements vertically and horizontically. 

#makefigure(vertical: false,
```typ
#quantum-circuit(
  row-spacing: 5pt,
  column-spacing: 5pt,
  1, gate($A$), gate($B$), 1, [\ ],
  1, 1, gate($S$), 1
)
```, quantum-circuit(
  row-spacing: 5pt,
  column-spacing: 5pt,
  1, gate($A$), swap(1), gate($B$), 1, [\ ],
  1, 1, targX(), gate($S$), 1
))

The `wire`, `color` and `fill` options provide means to customize line strokes and colors. This allows us to easily create "dark-mode" circuits:

#makefigure(vertical: false,
```typ
#box(fill: black, quantum-circuit(
  wire: .7pt + white, // Wire and stroke color
  color: white,       // Default foreground and text color
  fill: black,        // Gate fill color
  1, gate($X$), ctrl(1), rstick([*?*]), [\ ],
  1,1, targ(), meter(), 
))
```, box(fill: black, quantum-circuit(
  wire: .7pt + white, // Wire and stroke color
  color: white,       // Default foreground and text color
  fill: black,        // Gate fill color
  1, gate($X$), ctrl(1), rstick([*?*]), [\ ],
  1,1, targ(), meter(), 
)))

Furthermore, a common task is changing the total size of a circuit by scaling it up or down. Instead of tweaking all the parameters like `font-size`, `padding`, `row-spacing` etc. you can specify the `scale-factor` option which takes a percentage value:

#makefigure(vertical: false,
```typ
#quantum-circuit(
  scale-factor: 60%,
  1, gate($H$), ctrl(1), gate($H$), 1, [\ ],
  1, 1, targ(), 2
)
```, quantum-circuit(
  scale-factor: 60%,
  1, gate($H$), ctrl(1), gate($H$), 1, [\ ],
  1, 1, targ(), 2
))

Note, that this is different than calling Typst's builtin `scale()` function on the circuit which would scale it without affecting the layout, thus still reserving the same space as if unscaled!

For an optimally layout, the height for each row is determined by the gates on that wire. For this reason, the wires can have different distances. To better see the effect, let's decrease the `row-spacing`:

#makefigure(vertical: false,
```typ
#quantum-circuit(
    row-spacing: 2pt, min-row-height: 4pt,
    1, gate($H$), ctrl(1), gate($H$), 1, [\ ],
    1, gate($H$), targ(), gate($H$), 1, [\ ],
    2, ctrl(1), 2, [\ ],
    1, gate($H$), targ(), gate($H$), 1
)
```, quantum-circuit(
    row-spacing: 2pt,
    min-row-height: 0pt,
    1, gate($H$), ctrl(1), gate($H$), 1, [\ ],
    1, gate($H$), targ(), gate($H$), 1, [\ ],
    2, ctrl(1), 2, [\ ],
    1, gate($H$), targ(), gate($H$), 1
  ))

Setting the option `equal-row-heights` to `true` solves this problem (manually spacing the wires with lengths is still possible, see @fine-tuning):

#makefigure(vertical: false,
```typ
#quantum-circuit(
    equal-row-heights: true,
    row-spacing: 2pt, min-row-height: 4pt,
    1, gate($H$), ctrl(1), gate($H$), 1, [\ ],
    1, gate($H$), targ(), gate($H$), 1, [\ ],
    2, ctrl(1), 2, [\ ],
    1, gate($H$), targ(), gate($H$), 1
)
```, quantum-circuit(
    equal-row-heights: true,
    row-spacing: 2pt,
    min-row-height: 4pt,
    1, gate($H$), ctrl(1), gate($H$), 1, [\ ],
    1, gate($H$), targ(), gate($H$), 1, [\ ],
    2, ctrl(1), 2, [\ ],
    1, gate($H$), targ(), gate($H$), 1
  ))

// #makefigure(vertical: false,
// ```typ
// #quantum-circuit(
//   scale-factor: 60%,
//   1, gate($H$), ctrl(1), gate($H$), 1, [\ ],
//   1, 1, targ(), 2
// )
// ```, [
//   #quantum-circuit(
//     baseline: "=",
//     2, ctrl(1), 2, [\ ],
//     1, gate($H$), targ(), gate($H$), 1
//   ) =
//   #quantum-circuit(
//     baseline: "=",
//     phantom(), ctrl(1),  1, [\ ],
//      phantom(content: $H$), ctrl(0), phantom(content: $H$),
//   )
// ])


There is another option for #ref-fn("quantum-circuit()") that has a lot of impact on the looks of the diagram: `gate-padding`. This at the same time controls the default gate box padding and the distance of `lstick`'s and `rstick`'s to the wire. Need really wide or tight circuits?

#makefigure(vertical: false,
```typ
#quantum-circuit(
    gate-padding: 2pt,
    row-spacing: 5pt, column-spacing: 7pt,
    lstick($|0〉$, num-qubits: 3), gate($H$), ctrl(1), 
      ctrl(2), 1, rstick("GHZ", num-qubits: 3), [\ ],
    1, gate($H$), ctrl(0), 1, gate($H$), 1, [\ ],
    1, gate($H$), 1, ctrl(0), gate($H$), 1, [\ ],
)
```, quantum-circuit(
    gate-padding: 2pt,
    row-spacing: 5pt, column-spacing: 7pt,
    lstick($|0〉$, num-qubits: 3), gate($H$), ctrl(1), ctrl(2), 1, rstick("GHZ", num-qubits: 3), [\ ],
    1, gate($H$), ctrl(0), 1, gate($H$), 1, [\ ],
    1, gate($H$), 1, ctrl(0), gate($H$), 1, [\ ],
  )
)


#pagebreak()

= Gate Gallery <gate-gallery>


#table(align: center + horizon, columns: 6, column-gutter: (0pt, 0pt, 2.5pt, 0pt, 0pt),
  [Normal gate], quantum-circuit(1, gate($H$), 1), raw(lang: "typc", "gate($H$)"), 
  [Round gate], quantum-circuit(1, gate($X$, radius: 100%), 1), raw(lang: "typc", "gate($X$, \nradius: 100%)"), 
  [D gate], quantum-circuit(1, gate($Y$, radius: (right: 100%)), 1), raw(lang: "typc", "gate($Y$, radius: \n(right: 100%))"), 
  [Meter], quantum-circuit(1, meter(), 1), raw(lang: "typc", "meter()"), 
  [Meter with \ label], quantum-circuit(circuit-padding: (top: 1em), 1, meter(label: $lr(|±〉)$), 1), raw(lang: "typc", "meter(label: \n$lr(|±〉)$)"), 
  [Phase gate], quantum-circuit(1, phase($α$), 1), raw(lang: "typc", "phase($α$)"), 
  [Control], quantum-circuit(1, ctrl(0), 1), raw(lang: "typc", "ctrl(0)"), 
  [Open control], quantum-circuit(1, ctrl(0, open: true), 1), raw(lang: "typc", "ctrl(0, open: true)"), 
  [Target], quantum-circuit(1, targ(), 1), raw(lang: "typc", "targ()"), 
  [Swap target], quantum-circuit(1, targX(), 1), raw(lang: "typc", "targX()"), 
  [Permutation \ gate], quantum-circuit(1, permute(2,0,1), 1, [\ ], 3, [\ ], 3), raw(lang: "typc", "permute(2,0,1)"), 
  [Multiqubit \ gate], quantum-circuit(1, mqgate($U$, 3), 1, [\ ], 3, [\ ], 3), raw(lang: "typc", "mqgate($U$, 3)"), 
  [lstick], quantum-circuit(lstick($|psi〉$), 2), raw(lang: "typc", "lstick($|psi〉$)"), 
  [rstick], quantum-circuit(2, rstick($|psi〉$)), raw(lang: "typc", "rstick($|psi〉$)"), 
  [Multi-qubit \ lstick], quantum-circuit(row-spacing: 10pt, lstick($|psi〉$, num-qubits: 2), 2, [\ ], 3), raw(lang: "typc", "lstick($|psi〉$, \nnum-qubits: 2)"), 
  [Multi-qubit \ rstick], quantum-circuit(row-spacing: 10pt,2, rstick($|psi〉$, num-qubits: 2, brace: "]"),[\ ], 3), raw(lang: "typc", "rstick($|psi〉$, \nnum-qubits: 2, \nbrace: \"]\")"), 
  [midstick], quantum-circuit(1, midstick("yeah"),1), raw(lang: "typc", "midstick(\"yeah\")"), 
  [Wire bundle], quantum-circuit(1, nwire(5), 1), raw(lang: "typc", "nwire(5)"), 
  [Controlled \  #smallcaps("z")-gate], quantum-circuit(1, ctrl(1), 1, [\ ], 1, ctrl(0), 1), [#raw(lang: "typc", "ctrl(1)") \ + \ #raw(lang: "typc", "ctrl(0)")], 
  [Controlled \  #smallcaps("x")-gate], quantum-circuit(1, ctrl(1), 1, [\ ], 1, targ(), 1), [#raw(lang: "typc", "ctrl(1)") \ + \ #raw(lang: "typc", "targ()")], 
  [Swap \  gate], quantum-circuit(1, swap(1), 1, [\ ], 1, targX(), 1), [#raw(lang: "typc", "swap(1)") \ + \ #raw(lang: "typc", "targX()")], 
  [Controlled \ Hadamard], quantum-circuit(1, controlled($H$, 1), 1, [\ ], 1, ctrl(0), 1), [#raw(lang: "typc", "controlled($H$, 1)") \ + \ #raw(lang: "typc", "ctrl(0)")], 
  [Meter to \ classical], quantum-circuit(1, meter(target: 1), 1, [\ ], setwire(2), 1, ctrl(0), 1), [#raw(lang: "typc", "meter(target: 1)") \ + \ #raw(lang: "typc", "ctrl(0)")],   
)
#pagebreak()



= Fine-Tuning <fine-tuning>

// Many options allow to 

The #ref-fn("quantum-circuit()") command allows not only gates as well as content and string items but only length parameters which can be used to tweak the appearance of the circuit. Inserting a length value between gates adds a *horizontal space* of that length between the cells:

#makefigure(vertical: false,
text(size: .8em, ```typ
#quantum-circuit(
  gate($X$), gate($Y$), 10pt, gate($Z$)
)
```), quantum-circuit(
  gate($X$), gate($Y$), 10pt, gate($Z$)
  )
)

In the background, this works like a grid gutter that is set to `0pt` by default. If a length value is inserted between the same two columns on different wires/rows, the maximum value is used for the space. In the same spirit, inserting multiple consecutive length values result in the largest being used, e.g., a `5pt, 10pt, 6pt` results in a `10pt` gutter in the corresponding position. 

Putting a a length after the wire break item `[\ ]` produces a *vertical space* between the corresponding wires:

#makefigure(vertical: false,
text(size: .8em, ```typ
#quantum-circuit(
  gate($X$), [\ ], gate($Y$), [\ ], 10pt, gate($Z$)
)
```), quantum-circuit(
  gate($X$), [\ ], gate($Y$), [\ ], 10pt, gate($Z$)
  )
)



#pagebreak()

= Annotations

*Quantum-Circuit* provides a way of making custom annotations through the #ref-fn("annotate()") interface. An `annotate()` object may be placed anywhere in the circuit, the position only matters for the draw order in case several annotations would overlap. 


The `annotate()` command allows for querying cell coordinates of the circuit and passing in a custom draw function to draw globally in the circuit diagram. // This way, basically any decoration

Let's look at an example:

#makefigure(vertical: false,
text(size: .8em, ```typ
#quantum-circuit(
  1, ctrl(1), gate($H$), meter(), [\ ],
  1, targ(), 1, meter(),
  annotate(0, (2, 4), 
    (y, (x1, x2)) => { 
      let brace = math.lr($#box(height: x2 - x1)}$)
      place(dx: x1, dy: y, rotate(brace, -90deg, origin: top))
      let content = [Readout circuit]
      style(styles => {
        let size = measure(content, styles)
        place(dx: x1 + (x2 - x1)/2 - size.width/2, dy: y - .6em - size.height, content)
      })
  })
)
```), quantum-circuit(
  1, ctrl(1), gate($H$), meter(), [\ ],
  1, targ(), 1, meter(),
  annotate(0, (2, 4),
    (y, (x1, x2)) => { 
      let brace = math.lr($#box(height: x2 - x1)}$)
      place(dx: x1, dy: y, rotate(brace, -90deg, origin: top))
      let content = [Readout circuit]
      style(styles => {
        let size = measure(content, styles)
        place(dx: x1 + (x2 - x1)/2 - size.width/2, dy: y - .6em - size.height, content)
      })
  })
  )
)

First, the call to `annotate()` asks for the $y$ coordinate of the zeroth row (first wire) and the $x$ coordinates of the second and forth column. The draw callback function then gets the corresponding coordinates as arguments and uses them to draw a brace and some text above the cells. 

Note, that the circuit does not know how large the annotation is. If it goes beyond the circuits bounds, you may want to adjust the parameter `circuit-padding` of #ref-fn("quantum-circuit()") appropriately. 

Another example, here we want to obtain coordinates for the cell centers. We can achieve this by adding $0.5$ to the cell index. The fractional part of the number represents a percentage of the cell width/height. 

#makefigure(vertical: false,
text(```typ
#quantum-circuit(
  1, gate($X$), 2, [\ ],
  1, 2, gate($Y$), [\ ],
  1, 1, gate($H$), meter(), 
  annotate((0.5, 1.5, 2.5), (1.5, 3.5, 2.5),
    ((y0, y1, y2), (x0, x1, x2)) => { 
      path(
        (x0, y0), (x1, y1), (x2, y2), 
        closed: true, 
        fill: rgb("#1020EE50"), stroke: .5pt + black
      )
  })
)
```), quantum-circuit(
  1, gate($X$), 2, [\ ],
  1, 2, gate($Y$), [\ ],
  1, 1, gate($H$), meter(), 
  annotate((0.5, 1.5, 2.5), (1.5, 3.5, 2.5),
    ((y0, y1, y2), (x0, x1, x2)) => { 
      path(
        (x0, y0), (x1, y1), (x2, y2), 
        closed: true, 
        fill: rgb("#1020EE50"), stroke: .5pt + black
      )
  })
)
)


#let annotate-circuit(scale-factor: 100%) = quantum-circuit(
  // gate-padding: 30pt,
  circuit-padding: (top: 1.5em, bottom: 1.5em),
  scale-factor: scale-factor,
  lstick($|psi〉_C$), ctrl(1), gate($H$), meter(), setwire(2), ctrl(2, wire-count:2), [\ ],
  lstick($|Phi〉_A^+$), targ(), meter(), setwire(2), ctrl(1, wire-count:2), [\ ],
  lstick($|Phi〉_B^+$),1,nwire(2), targ(fill: true), ctrl(0),1, rstick($|psi〉_B$), 
  annotate(0, (2, 4), (y, cols) => { 
    let (x1, x2) = cols
    place(dx: x1, dy: y, rotate(math.lr($#box(height: x2 - x1)}$), -90deg, origin: top))
    let content = [Two Instructions]
    style(styles => {
      let size = measure(content, styles)
      place(dx: x1 + (x2 - x1)/2 - size.width/2, dy: y - .6em - size.height, content)
    })
  }),
  annotate(3, (2, 6), (y, cols) => {
    let (x1, x2) = cols
    place(dx: x1, dy: y, rotate(math.lr(${#box(height: x2 - x1)$), -90deg, origin: top))
    let content = [Some weird stuff]
    style(styles => {
      let size = measure(content, styles)
      place(dx: x1+(x2 -x1)/2 - size.width/2, dy: y + .5em, content)
    })
  }) 
)

// #annotate-circuit()

#pagebreak()
= Function Documentation



#set text(size: 9pt)

#show raw.where(block: false): box.with(
  fill: luma(240),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
)
// // Display block code in a larger block
// // with more padding.
// #show raw.where(block: true): block.with(
//   fill: luma(240),
//   inset: 10pt,
//   radius: 4pt,
// )


// #let type-colors = (
//   "content": rgb("#a6ebe6"),
//   "color": rgb("#a6ebe6"),
//   "string": rgb("#d1ffe2"),
//   "none": rgb("#ffcbc4"),
//   "auto": rgb("#ffcbc4"),
//   "boolean": rgb("#ffedc1"),
//   "integer": rgb("#e7d9ff"),
//   "float": rgb("#e7d9ff"),
//   "ratio": rgb("#e7d9ff"),
//   "length": rgb("#e7d9ff"),
//   "angle": rgb("#e7d9ff"),
//   "relative-length": rgb("#e7d9ff"),
//   "fraction": rgb("#e7d9ff"),
//   "symbol": rgb("#eff0f3"),
//   "array": rgb("#eff0f3"),
//   "dictionary": rgb("#eff0f3"),
//   "arguments": rgb("#eff0f3"),
//   "selector": rgb("#eff0f3"),
//   "module": rgb("#eff0f3"),
//   "stroke": rgb("#eff0f3"),
//   "function": rgb("#f9dfff"),
// )

#show raw.where(lang: "typ-doc"): it => {
  // set text(bottom-edge: "descender")
  // let start = 
  set text(size: .9em)
  // set par(leading: .7em)
  // show par: set block(spacing: )
  let pos = it.text.position("(")
  if pos == none { pos = 0}
  text(it.text.slice(0, pos), fill: blue.darken(30%).lighten(20%))
  let arg-box(content, color) = { style(styles => {
    h(2pt)
    box(outset: 2pt, fill: color, radius: 2pt, content)
    h(2pt)
    })
  }
  // show "content-type": arg-box("content", rgb("#a6ebe6"))
  show "color-type": arg-box("color", rgb("#a6ebe6"))
  show "string-type": arg-box("string", rgb("#d1ffe2"))
  show "none-type": arg-box("none", rgb("#ffcbc4"))
  show "auto-type": arg-box("auto", rgb("#ffcbc4"))
  show "boolean-type": arg-box("boolean", rgb("#ffedc1"))
  show "integer-type": arg-box("integer", rgb("#e7d9ff"))
  show "float-type": arg-box("float", rgb("#e7d9ff"))
  show "ratio-type": arg-box("ratio", rgb("#e7d9ff"))
  show "length-type": arg-box("length", rgb("#e7d9ff"))
  show "angle-type": arg-box("angle", rgb("#e7d9ff"))
  show "relative-length-type": arg-box("relative-length", rgb("#e7d9ff"))
  show "fraction-type": arg-box("fraction", rgb("#e7d9ff"))
  show "symbol-type": arg-box("symbol", rgb("#eff0f3"))
  show "array-type": arg-box("array", rgb("#eff0f3"))
  show "dictionary-type": arg-box("dictionary", rgb("#eff0f3"))
  show "arguments-type": arg-box("arguments", rgb("#eff0f3"))
  show "selector-type": arg-box("selector", rgb("#eff0f3"))
  show "module-type": arg-box("module", rgb("#eff0f3"))
  show "stroke-type": arg-box("stroke", rgb("#eff0f3"))
  show "function-type": arg-box("function", rgb("#f9dfff"))
  it.text.slice(pos)
}

```typ-doc
gate(
  content-type string-type,
  arg: string-type none-type auto-type boolean-type
  a: integer-type symbol-type
  function-type float-type
)
```

// ```typ-doc
// gate(
//   fill: none-type color-type,
//   radius: length-type,
//   box: boolean-type,
//   floating: boolean-type,
//   wire-count: integer-type,
//   multi: none-type dictionary-type,
//   size-hint: function-type,
//   draw-function: function-type,
//   gate-type: string-type, 
//   content-type,
//   ..args array-type
// ) -> dictionary-type
// ```




// #let param-block(name, types, content, default: "?") = block(
//   inset: 10pt, fill: luma(98%), width: 100%,
//   breakable: false,
//   [
//   #text(weight: "bold", size: 1.2em, name) #h(.5cm) #types.map(x => raw(lang: "typ-doc", x)).join([ #text("or",size:.6em) ])

//   #content
  
//   #if default != "?" [
//     Default: #raw(lang: "typc", repr(default))
//   ]
// ])

// #param-block("wire", ("stroke-type",), [The wire style], default: 0.7pt + black)
// #param-block("fill", ("none-type","color-type"), [The fill color for the gate], default: none)




// ```typ-doc
// quantum-circuit(
//   wire: stroke-type,
//   row-spacing: length-type,
//   column-spacing: length-type,
//   min-row-height: length-type,
//   min-column-width: length-type
//   gate-padding: .length-type,
//   equal-row-heights: boolean-type,
//   color: color-type,
//   fill: color-type,
//   background: color-type,
//   fontsize: length-type,
//   scale-factor: ratio-type,
//   circuit-padding: dictionary-type,
//   ..content array-type
// ) -> content-type
// ```


#import "typst-doc.typ": parse-module, show-module, show-outline

#show heading.where(level: 3): it => {
  align(center, it)
}
#show heading: set text(size: 1.2em)

#columns(2,[
  
This section contains a complete reference for every function in *quantum-circuit*. 


#set heading(numbering: none)
#{
  let docs = parse-module("/../../quantum-circuit.typ")

  let gates = docs
  gates.functions = gates.functions.filter(
    x => x.name in ("gate", "mqgate", "meter", "permute", "phantom", "ctrl", "targ", "targX", "swap", "control", "phase", "controlled"))

  let decorations = docs
  decorations.functions = decorations.functions.filter(
    x => x.name in ("lstick", "rstick", "midstick", "nwire", "slice", "annotate", "gategroup", "setwire"))

  let circuit = docs
  circuit.functions = circuit.functions.filter(
    x => x.name in ("quantum-circuit"))

  [*Gates*]
  show-outline(gates)
  [*Decorations*]
  show-outline(decorations)
  [*Quantum Circuit*]
  show-outline(circuit)
  show-module(docs, show-module-name: false, first-heading-level: 2)
}
])





#pagebreak()
= Demo <demo>

This section demonstrates the use of the *quantum-circuit* library by reproducing some figures from the famous book _Quantum Computation and Quantum Information_ by Nielsen and Chuang #cite("nielsen_2022_quantum").

== Quantum teleportation
Quantum teleportation circuit reproducing the Figure 4.15 in #cite("nielsen_2022_quantum"). 
#example-code("../../examples/teleportation.typ")


== Quantum phase estimation
Quantum phase estimation circuit reproducing the Figure 5.2 in #cite("nielsen_2022_quantum"). 
#example-code("../../examples/phase-estimation.typ")

#pagebreak()


== Quantum Fourier transform:
Circuit for performing the quantum Fourier transform, reproducing the Figure 5.1 in #cite("nielsen_2022_quantum"). 
#example-code("../../examples/qft.typ")


== Shor Nine Qubit Code

Encoding circuit for the Shor nine qubit code. This diagram repdoduces Figure 10.4 in #cite("nielsen_2022_quantum")

#table(columns: (2fr, 1fr), align: horizon, stroke: none,
makefigure(text(size: .9em, ```typ
#let ancillas = (setwire(0), 5, lstick($|0〉$), setwire(1), targ(), 2, [\ ],
setwire(0), 5, lstick($|0〉$), setwire(1), 1, targ(), 1, [\ ])

#quantum-circuit(
  scale-factor: 80%,
  lstick($|ψ〉$), 1, 10pt, ctrl(3), ctrl(6), gate($H$), 1, 15pt, 
    ctrl(1), ctrl(2), 1, [\ ],
  ..ancillas,
  lstick($|0〉$), 1, targ(), 1, gate($H$), 1, ctrl(1), ctrl(2), 
    1, [\ ],
  ..ancillas,
  lstick($|0〉$), 2, targ(),  gate($H$), 1, ctrl(1), ctrl(2), 
    1, [\ ],
  ..ancillas
)```), {
  }
), {
  let ancillas = (setwire(0), 5, lstick($|0〉$), setwire(1), targ(), 2, [\ ],
  setwire(0), 5, lstick($|0〉$), setwire(1), 1, targ(), 1, [\ ])
  
  quantum-circuit(
  scale-factor: 80%,
  lstick($|ψ〉$), 1, ctrl(3), ctrl(6), gate($H$), 1, 15pt, ctrl(1), ctrl(2), 1, [\ ],
  ..ancillas,
  lstick($|0〉$), 1, targ(), 1, gate($H$), 1, ctrl(1), ctrl(2), 1, [\ ],
  ..ancillas,
  lstick($|0〉$), 2, targ(),  gate($H$), 1, ctrl(1), ctrl(2), 1, [\ ],
  ..ancillas
)}
)

#pagebreak()


== Fault-Tolerant Measurement

Circuit for performing fault-tolerant measurement (as Figure 10.28 in #cite("nielsen_2022_quantum")). 
#example-code("../../examples/fault-tolerant-measurement.typ")


== Fault-Tolerant Gate Construction
The following two circuits reproduce figures from Exercise 10.66 and 10.68 on construction fault-tolerant $pi/8$ and Toffoli gates in #cite("nielsen_2022_quantum").
#example-code("../../examples/fault-tolerant-pi8.typ")
#example-code("../../examples/fault-tolerant-toffoli1.typ")
#example-code("../../examples/fault-tolerant-toffoli2.typ")


// #pagebreak()
#bibliography("references.bib")