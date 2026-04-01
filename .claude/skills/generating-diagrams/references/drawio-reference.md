# draw.io XML Reference

## Basic Structure

Every diagram must have this structure:

```xml
<mxGraphModel>
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <!-- Diagram cells go here with parent="1" -->
  </root>
</mxGraphModel>
```

- Cell `id="0"` is the root layer
- Cell `id="1"` is the default parent layer
- All diagram elements use `parent="1"` unless using multiple layers

## Common Shapes

**Rounded rectangle:**
```xml
<mxCell id="2" value="Label" style="rounded=1;whiteSpace=wrap;" vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="120" height="60" as="geometry"/>
</mxCell>
```

**Diamond (decision):**
```xml
<mxCell id="3" value="Condition?" style="rhombus;whiteSpace=wrap;" vertex="1" parent="1">
  <mxGeometry x="100" y="200" width="120" height="80" as="geometry"/>
</mxCell>
```

**Arrow (edge):**
```xml
<mxCell id="4" value="" style="edgeStyle=orthogonalEdgeStyle;" edge="1" source="2" target="3" parent="1">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

**Labeled arrow:**
```xml
<mxCell id="5" value="Yes" style="edgeStyle=orthogonalEdgeStyle;" edge="1" source="3" target="6" parent="1">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

## Style Properties

| Property | Values | Use for |
|----------|--------|---------|
| `rounded=1` | 0 or 1 | Rounded corners |
| `whiteSpace=wrap` | wrap | Text wrapping |
| `fillColor=#dae8fc` | Hex color | Background color |
| `strokeColor=#6c8ebf` | Hex color | Border color |
| `fontColor=#333333` | Hex color | Text color |
| `shape=cylinder3` | shape name | Database cylinders |
| `shape=mxgraph.flowchart.document` | shape name | Document shapes |
| `ellipse` | style keyword | Circles/ovals |
| `rhombus` | style keyword | Diamonds |
| `edgeStyle=orthogonalEdgeStyle` | style keyword | Right-angle connectors |
| `edgeStyle=elbowEdgeStyle` | style keyword | Elbow connectors |
| `dashed=1` | 0 or 1 | Dashed lines |
| `swimlane` | style keyword | Swimlane containers |
