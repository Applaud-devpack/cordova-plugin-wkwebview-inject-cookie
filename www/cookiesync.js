var exec = require("cordova/exec");

module.exports = {
    setCookie: function (domain, path, name, value, expire, secure, maxAge, successCallback, errorCallback) {
        var expireDate = (expire ? expire.toISOString() : null);

        exec(successCallback, errorCallback, "WKWebViewInjectCookie",
            "setCookie", [domain, path, name || "foo", value || "bar", expireDate, secure, maxAge || 2592000]);
    },

    getCookies: function (url, successCallback, errorCallback) {
        exec(successCallback, errorCallback, "WKWebViewInjectCookie",
            "getCookies", [url]);
    },

    injectCookie: function (domain, path = '', successCallback, errorCallback) {
        // Strip http* from domain if present
        if (domain.startsWith("http")) {
            var domainParts = domain.split("//");
            if (domainParts.length > 1) {
                domain = domainParts[1];
            }
        }

        // Ensure the path is not empty
        if (!path) {
            var sPos = domain.indexOf("/");
            if (sPos >= 0) {
                path = domain.substring(sPos);
                domain = domain.substring(0, sPos);
            }
        }

        // Ensure the path is at least a slash
        if (!path.endsWith('/')) {
            path = path + '/';
        }

        var expireDate = new Date();
        expireDate.setFullYear(expireDate.getFullYear() + 1);
        expireDate.setMonth(11); // December
        expireDate.setDate(31);  // 31st

        this.setCookie(domain, path, "foo", "bar", expireDate, true, 31536000, successCallback, errorCallback);
    }
};
