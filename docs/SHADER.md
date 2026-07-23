# SHADER STYLE

## 基本原則

- 使用可能な構文・組み込み関数・組み込み変数を [Godot Shader Language](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html) で確認する。

## エントリ関数の制約

- `vertex()`、`fragment()`、`light()` は Godot が呼び出す `void` のエントリ関数である。
- これらのエントリ関数内で早期 `return` を使用してはならない。Godot Shader Language ではコンパイルエラーになる。
- 条件によって処理を打ち切りたい場合は、`if / else` で分岐し、各分岐で出力変数を代入する。

```glsl
void fragment() {
	if (is_outside_screen) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		COLOR = texture(screen_texture, SCREEN_UV);
	}
}
```
