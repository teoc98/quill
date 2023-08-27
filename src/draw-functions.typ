// INTERNAL GATE DRAW FUNCTIONS


#import "utility.typ"
#import "arrow.typ"



// Default gate draw function. Draws a box with global padding
// and the gates content. Stroke and default fill are only applied if 
// gate.box is true
#let draw-boxed-gate(gate, draw-params) = align(center, box(
  inset: draw-params.padding, 
  width: gate.width,
  radius: gate.radius,
  stroke: if gate.box { draw-params.wire }, 
  fill: if gate.fill != none {gate.fill} else if gate.box {draw-params.background}, 
  gate.content,
))

// Same but without displaying a box
#let draw-unboxed-gate(gate, draw-params) = box(
  inset: draw-params.padding, 
  fill: if gate.fill != none {gate.fill} else {draw-params.background}, 
  gate.content
)

// Draw a gate spanning multiple wires
#let draw-boxed-multigate(gate, draw-params) = {
  let dy = draw-params.multi.wire-distance
  let extent = if gate.multi.extent == auto {draw-params.x-gate-size.height/2} else {gate.multi.extent}
  let style-params = (
      width: gate.width,
      stroke: draw-params.wire, 
      radius: gate.radius,
      fill: if gate.fill != none {gate.fill} else {draw-params.background}, 
      inset: draw-params.padding, 
  )
  align(center + horizon, box(
    ..style-params,
    height: dy + 2 * extent,
    gate.content
  ))
  
  
  let draw-inouts(inouts, alignment) = {
    
    if inouts != none and dy != 0pt {
      let width = measure(line(length: gate.width), draw-params.styles).width
      let y0 = -(dy + extent) - draw-params.center-y-coords.at(0)
      let get-wire-y(qubit) = { draw-params.center-y-coords.at(qubit) + y0 }
      set text(size: .8em)
      style(styles => {
        for input in inouts {
          let size = measure(input.label, styles)
          let y = get-wire-y(input.qubit)
          let label-x = draw-params.padding
          if "n" in input and input.n > 1 {
            let y2 = get-wire-y(input.qubit + input.n - 1)
            let brace = create-brace(auto, alignment, y2 - y + draw-params.padding)
            let brace-x = 0pt
            let size = measure(brace, styles)
            if alignment == right { brace-x += width - size.width }
            
            place(brace, dy: y - 0.5 * draw-params.padding, dx: brace-x)
            label-x = size.width
            y += 0.5 * (y2 - y)
          }
          place(dy: y - size.height / 2, align(
            alignment, 
            box(input.label, width: width, inset: (x: label-x))
          ))
        }
      })
      
    }
  
  }
  draw-inouts(gate.multi.inputs, left)
  draw-inouts(gate.multi.outputs, right)
}

#let draw-targ(item, draw-params) = {
  let size = item.data.size
  box[
    #circle(
      radius: size, 
      stroke: draw-params.wire, 
      fill: if item.fill == none {none} 
        else { 
          if item.fill == true {draw-params.background} 
          else if type(item.fill) == "color" {item.fill} 
        }
    )
    #place(line(start: (size, 0pt), length: 2*size, angle: -90deg, stroke: draw-params.wire))
    #place(line(start: (0pt, -size), length: 2*size, stroke: draw-params.wire))
  ]
}

#let draw-ctrl(gate, draw-params) = {
  let clr = draw-params.wire
  let color = utility.if-none(gate.fill, draw-params.color)
  if "show-dot" in gate.data and not gate.data.show-dot { return none }
  if gate.data.open {
    let stroke = utility.if-none(gate.fill, draw-params.wire)
    box(circle(stroke: stroke, fill: draw-params.background, radius: gate.data.size))
  } else {
    box(circle(fill: color, radius: gate.data.size))
  }
}

#let draw-swap(gate, draw-params) = {
  box({
    let d = gate.data.size
    let stroke = draw-params.wire
    box(width: d, height: d, {
      place(line(start: (-0pt, -0pt), end: (d, d), stroke: stroke))
      place(line(start: (d, 0pt), end: (0pt, d), stroke: stroke))
    })
  })
}



#let draw-meter(gate, draw-params) = {
  let content = {
    set align(top)
    let stroke = draw-params.wire
    let padding = draw-params.padding
    let fill = utility.if-none(gate.fill, draw-params.background)
    let height = draw-params.x-gate-size.height 
    let width = 1.5 * height
    height -= 2 * padding
    width -= 2 * padding
    box(
      width: width, height: height, inset: 0pt, 
      {
        let center-x = width / 2
        place(path((0%, 110%), ((50%, 40%), (-40%, 0pt)), (100%, 110%), stroke: stroke))
        set align(left)
        arrow.draw-arrow((center-x, height * 1.2), (width * .9, height*.3), length: 3.8pt, width: 2.8pt, stroke: stroke, arrow-color: draw-params.color)
    })
  }
  gate.content = rect(content, inset: 0pt, stroke: none)
  if gate.multi != none and gate.multi.num-qubits > 1 {
    draw-boxed-multigate(gate, draw-params)
  } else {
    draw-boxed-gate(gate, draw-params)
  }
}


#let draw-nwire(gate, draw-params) = {
  set text(size: .7em)
  let size = measure(gate.content, draw-params.styles)
  let extent = 2.5pt + size.height
  box(height: 2 * extent, { // box is solely for height hint
    place(dx: 1pt, dy: 0pt, gate.content)
    place(dy: extent, line(start: (0pt,-4pt), end: (-5pt,4pt), stroke: draw-params.wire))
  })
}



#let draw-permutation-gate(gate, draw-params) = {
  let dy = draw-params.multi.wire-distance
  let width = gate.width
  if dy == 0pt { return box(width: width, height: 4pt) }
  box(
    height: dy + 4pt,
    inset: (y: 2pt),
    fill: draw-params.background,
    width: width, {
      let qubits = gate.data.qubits
      let y0 = draw-params.center-y-coords.at(gate.qubit)
      for from in range(qubits.len()) {
        let to = qubits.at(from)
        let y-from = draw-params.center-y-coords.at(from + gate.qubit) - y0
        let y-to = draw-params.center-y-coords.at(to + gate.qubit) - y0
        place(path(((0pt,y-from), (-width/2, 0pt)), ((width, y-to), (-width/2, 0pt)), stroke: 3pt + draw-params.background))
        place(path(((-.1pt,y-from), (-width/2, 0pt)), ((width+.1pt, y-to), (-width/2, 0pt)), stroke: draw-params.wire)) 
      }
    }
  )
}

// create a sized brace with given length. 
// `brace` can be auto, defaulting to "{" if alignment is right
// and "}" if alignment is left. 
#let create-brace(brace, alignment, length) = {
  let brace-symbol = if brace == auto {
      if alignment == right {"{"} else {"}"} 
    } else { brace }
  return $ lr(#brace-symbol#block(height: length)) $
}


// Draw an lstick (align: "right") or rstick (align: "left")
#let draw-lrstick(gate, draw-params, align: none) = {
  assert(align in ("left", "right"), message: "Only left and right are allowed")
  let isleftstick = (align == "right")
  let draw-brace = gate.data.brace != none
    
  let content = box(inset: draw-params.padding, gate.content)
  let size = measure(content, draw-params.styles)
  
 
  let brace = none
  
  if draw-brace {
   let brace-symbol = if gate.data.brace == auto {
        if gate.multi != none { if isleftstick {"{"} else {"}"} }
        } else { gate.data.brace }
    let brace-height
    if gate.multi == none {
      brace-height = 1em + 2 * draw-params.padding
    } else {
      brace-height = draw-params.multi.wire-distance + .5em
    }
    let brace-symbol = gate.data.brace
    if brace-symbol == auto and gate.multi == none {
      brace-symbol = none
    }
    brace = create-brace(brace-symbol, if isleftstick {right}else{left}, brace-height)
  }
  
  let brace-size = measure(brace, draw-params.styles)
  let width = size.width + brace-size.width
  let height = size.height
  let brace-offset-y
  let content-offset-y = 0pt
  
  if gate.multi == none {
    brace-offset-y = size.height/2 - brace-size.height/2
  } else {
    let dy = draw-params.multi.wire-distance
    // at layout stage:
    if dy == 0pt { return box(width: 2 * width, height: 0pt, content) }
    height = dy
    content-offset-y = -size.height/2 + height/2
    brace-offset-y = -.25em
  }
  
  let inset = (:)
  inset.insert(align, width)
  let brace-pos-x = if isleftstick { size.width } else { 0pt }
  let content-pos-x = if isleftstick { 0pt } else { brace-size.width }

  move(dy: 0pt,
    box(width: 2 * width, height: height,
    inset: inset, 
      {
        place(brace, dy: brace-offset-y, dx: brace-pos-x)
        place(content, dy: content-offset-y, dx: content-pos-x)
      }
  ))
}