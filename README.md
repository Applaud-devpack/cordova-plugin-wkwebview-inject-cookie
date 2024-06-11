# cordova-plugin-wkwebview-inject-cookie

When switching to `WKWebView` in Cordova for iOS, some plugins have the known issue that cookies won't be used properly on the very first start of the application, or every time using the iOS Simulator. In particular, session cookies. This is due to a [missing proper sync between the underlying WKHTTPCookieStore and the WebView](https://stackoverflow.com/a/49534854/2757879).

While this issue could probably only get fixed by Apple, there is a simple workaround available to get it working: Once a dummy cookie is placed into the `WKHTTPCookieStore` manually, the synchronization gets triggered (started) and it won't bug you ever again.

## Compatibility

This workaround works for iOS 11 and later. It requires specifying the domain for which the cookie should be set.

## Usage

Add an event listener for the `deviceready` event in your JavaScript code and call the `injectCookie` method with your domain and path.

### Example

```javascript
document.addEventListener('deviceready', () => {
  wkWebView.injectCookie('mydomain.com', 'mypath', 
    () => {
      console.log('Cookie injected successfully');
    },
    (error) => {
      console.error('Error injecting cookie', error);
    });
});
```

Replace `"mydomain.com"` with your actual domain and `"mypath"` with the appropriate path. If you don't need to specify a path, you can leave it empty (just ensure you keep the trailing slash to indicate no extra path).

### Success and Error Handlers

You can optionally pass a success and an error handler to the `injectCookie` method. The success handler will be called if the cookie was injected properly, and the error handler will be called if not.

### Full Usage Example

```javascript
document.addEventListener('deviceready', () => {
  wkWebView.injectCookie('mydomain.com', 'mypath', 
    () => {
      console.log('Cookie injected successfully');
    },
    (error) => {
      console.error('Error injecting cookie', error);
    });
});
```