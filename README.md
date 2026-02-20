## 1. Installation
To install the plugin with the Cordova CLI:

```
$ cordova plugin add git+ssh://git@gitlab.proxym-group.net:3022/2026_pifss_migrationbybankerise/custom-plugin-keycloak.git
```

## 2. Usage
Here is a usage example:

```js
function login() {
                cordova.plugins.BankeriseKeycloakAuthentication.isAvailable(function (available) {
                    if (available) {
                        cordova.plugins.BankeriseKeycloakAuthentication.show({
                            url: 'http://auth.albaraka.dev.proxym-it.tn/auth/realms/al-baraka-front/protocol/openid-connect/auth?client_id=albaraka-front&redirect_uri=albaraka%3A%2F%2Fcallback&response_type=code&scope=openid+offline_access',
                            animated: true, // default true, note that 'hide' will reuse this preference
                            hidden: false, // default false
                            scheme: 'albaraka' // the url scheme you will be rediected to, note that your application needs to support that url scheme
                        }, function(result) {
                            if (result.event === 'opened') {
                                console.log('opened');
                            } else if (result.event === 'loaded') {
                                console.log('loaded');
                            } else if (result.event === 'closed') {
                                console.log('closed');
                            }
                        }, function(msg) {
                            console.log("KO: " + JSON.stringify(msg));
                        })
                    } else {
                        // potentially powered by InAppBrowser because that (currently) clobbers window.open
                        window.open(url /*, '_blank', 'location=yes'*/);
                    }
                })
            }

function hideAuthenticationView() {
                cordova.plugins.BankeriseKeycloakAuthentication.hide()
            }
```

## 3. Demo

<a href="./demo.mp4" target="_blank">Tap here for a quick demo video.</a>
