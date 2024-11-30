# ClassNameExtractor

When using [Vite's CSS Modules feature](https://vitejs.dev/guide/features#css-modules) with PureScript, there are two main issues:
1. Since PureScript cannot directly import CSS, you need to prepare JavaScript code using [FFI](https://github.com/purescript/documentation/blob/master/guides/FFI.md) to import CSS and retrieve styles based on class name information, making it accessible from PureScript.
2. While `spago build` can output the JavaScript file that imports CSS and the compiled PureScript results to `output/`, the CSS files imported by JavaScript are not placed in `output`. As a result, Vite cannot resolve the CSS import part, causing build errors.

ClassNameExtractor solves these problems by providing FFI setup that can extract class names by parsing CSS for safe style resolution, and by providing functionality to place CSS in the `output` directory.

## Installation

If you want to use the internal implementation as a library, please install it from `spago`:
```bash
spago install class-name-extractor
```

If you want to use this tool as a CLI tool, install it from the NPM registry with the following command:
```bash
npm install -D @himanoa/class-name-extractor
```

## Usage

### Basic Usage

First, prepare your CSS module file. The file should use the `.module.css` extension:

```css
/* src/components/Button/styles.module.css */
.foo {
  display: flex
}
.bar {
  background-color: black;
}
```

Then, run the class-name-extractor command with the following arguments:
```bash
class-name-extractor <css-file-path> <purescript-module-name>
```

- `<css-file-path>`: Path to your CSS module file (e.g., `src/components/Button/styles.module.css`)
- `<purescript-module-name>`: The PureScript module name where you want to use these styles (e.g., `YourProject.Components.Button`)

Example:
```bash
class-name-extractor src/components/Button/styles.module.css YourProject.Components.Button
```

### Generated Files

The command will generate three files:

1. JavaScript FFI file:
```javascript
/* src/components/Button/Styles.js */

import s from './styles.module.css'
export const _styles = (name) => {
  return s[name]
}
```
This file imports the CSS module and provides a function to access the class names.

2. PureScript module file:
```purescript
-- src/components/Button/Styles.purs
module YourProject.Components.Button.Styles (foo, bar) where

foreign import _styles :: String -> String

foo :: String
foo = _styles "foo"
bar :: String
bar = _styles "bar"
```
This file exports the class names as PureScript functions that can be imported in your components.

3. CSS file in output directory:
```css
/* output/YourProject.Components.Button.Styles/styles.module.css */

.foo {
  display: flex
}
.bar {
  background-color: black;
}
```
This is a copy of your CSS file placed in the output directory for Vite to properly resolve the imports.

### Using in Your Components

You can use the generated styles in your PureScript components like this:

```purescript
module YourProject.Components.Button.Component where

import YourProject.Components.Button.Styles as Styles

button :: JSX
button = element "div" { className: Styles.foo } [ text "Button" ]
```

This ensures that:
- The class names are available as PureScript functions
- The CSS is properly imported and bundled by Vite
- You don't need to manually manage the FFI setup for CSS modules

## Feedback and Contributions

If you find any bugs or issues while using the tool, please create an Issue.

## LICENSE

MIT
