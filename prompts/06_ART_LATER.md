# Prompt 06 — Art direction for later ChatGPT image-generation session
Generate assets only when explicitly requested. Overall visual bible: minimalist neo-noir 2D pixel art for a side-scrolling platformer, crisp silhouette, simple readable stepped pixel shapes, cinematic neo-noir lighting, navy-charcoal shadows, cyan time power, warm amber practical lights, pale gold evidence, consistent camera and perspective, no written words, no logos, no UI. Maintain coherent scale and light source across assets.

Ball sprite request (separate invocation): single small glowing cyan-core rubber ball, subtle clock motif, expressive but not excessively detailed, front-side gameplay sprite, centered, full ball visible, transparent background, no shadow baked in, no ground, no additional objects, high-resolution square canvas.

Guard sprite request: single full-body masked goon silhouette, side-view neutral pose suitable for 2D platformer, full body inside transparent canvas, stepped pixel silhouettes, strong readable silhouette, no floor, no weapons required.

Background request: 16:9 wide background for [APARTMENT/WAREHOUSE/HEADQUARTERS], side-on 2D platformer environment, layered distant scenery and atmospheric lights, no gameplay platforms, no interactive crates, no guards, no text, no UI, keep ground-plane space visually open so Godot colliders and props can be overlaid independently. If foreground platforms are desired, request them as separate transparent assets.

Asset checklist: visually test against blue/amber palette; export as PNG or compatible Godot texture, ball and guard transparent, backgrounds wide. Never require exact art dimensions in scene scripts: scale via Sprite2D / TextureRect and exported settings; no code changes needed for replacement.
