package cordova.plugin.bankerise.keycloakauthentication;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;

import androidx.core.app.ActivityCompat;
import androidx.core.app.ActivityOptionsCompat;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import static cordova.plugin.bankerise.keycloakauthentication.SharedConstants.ACTIVATE_BACK_BUTTON_KEY;
import static cordova.plugin.bankerise.keycloakauthentication.SharedConstants.ANIMATED_ATTRIBUTE_KEY;
import static cordova.plugin.bankerise.keycloakauthentication.SharedConstants.ANIM_CONSTANT_KEY;
import static cordova.plugin.bankerise.keycloakauthentication.SharedConstants.SLIDE_IN_ANIMATION_KEY;
import static cordova.plugin.bankerise.keycloakauthentication.SharedConstants.SLIDE_OUT_ANIMATION_KEY;
import static cordova.plugin.bankerise.keycloakauthentication.SharedConstants.TRANSITION_ATTRIBUTE_KEY;
import static cordova.plugin.bankerise.keycloakauthentication.SharedConstants.URL_ATTRIBUTE_KEY;

public class BankeriseKeycloakAuthentication extends CordovaPlugin {

    public static final int CUSTOM_TAB_REQUEST_CODE = 1;

    private CallbackContext callbackContext;
    private Bundle mStartAnimationBundle;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        switch (action) {
            case "isAvailable":
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, this.isAvailable()));
                return true;
            case "show": {
                final JSONObject options = args.getJSONObject(0);
                final String url = options.optString(URL_ATTRIBUTE_KEY);
                final boolean activateBackButton = options.optBoolean(ACTIVATE_BACK_BUTTON_KEY, true);
                if (TextUtils.isEmpty(url)) {
                    JSONObject result = new JSONObject();
                    result.put("error", "expected argument 'url' to be non empty string.");
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, result);
                    callbackContext.sendPluginResult(pluginResult);
                    return true;
                }
                String transition = "";
                mStartAnimationBundle = null;
                final boolean animated = options.optBoolean(ANIMATED_ATTRIBUTE_KEY, true);
                if (animated) transition = options.optString(TRANSITION_ATTRIBUTE_KEY);
                PluginResult pluginResult;
                JSONObject result = new JSONObject();
                if (isAvailable()) {
                    try {
                        this.show(url, transition, activateBackButton);
                        /*
                          post event callback value as loaded
                         */
                        putActivityResult(result, "loaded");
                        pluginResult = new PluginResult(PluginResult.Status.OK, result);
                        pluginResult.setKeepCallback(true);
                        this.callbackContext = callbackContext;
                    } catch (Exception ex) {
                        result.put("error", ex.getMessage());
                        pluginResult = new PluginResult(PluginResult.Status.ERROR, result);
                    }
                } else {
                    result.put("error", "custom tabs are not available");
                    pluginResult = new PluginResult(PluginResult.Status.ERROR, result);
                }
                callbackContext.sendPluginResult(pluginResult);
                return true;
            }
        }
        return false;
    }

    private void putActivityResult(JSONObject result, String eventState) throws JSONException {
        result.put("event", eventState);
    }

    private boolean isAvailable() {
        return true;
    }

    private void show(String url, String transition, boolean activateBackButton) {
        Intent intent = new Intent(cordova.getActivity().getApplicationContext(), CordovaWebViewImplement.class);
        intent.putExtra("URL", url);
        intent.putExtra(ACTIVATE_BACK_BUTTON_KEY, activateBackButton);
        if (!TextUtils.isEmpty(transition))
            addTransition();
        startCustomTabActivity(intent);
    }

    private void addTransition() {
        mStartAnimationBundle = ActivityOptionsCompat.makeCustomAnimation(
                cordova.getActivity(), getIdentifier(SLIDE_IN_ANIMATION_KEY), getIdentifier(SLIDE_OUT_ANIMATION_KEY)).toBundle();
    }

    private void startCustomTabActivity(Intent intent) {
        if (mStartAnimationBundle == null)
            cordova.startActivityForResult(this, intent, CUSTOM_TAB_REQUEST_CODE);
        else {
            cordova.setActivityResultCallback(this);
            ActivityCompat.startActivityForResult(cordova.getActivity(), intent, CUSTOM_TAB_REQUEST_CODE, mStartAnimationBundle);
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        if (requestCode == CUSTOM_TAB_REQUEST_CODE) {
            JSONObject result = new JSONObject();
            try {
                putActivityResult(result, "closed");
            } catch (JSONException e) {
                e.printStackTrace();
            }

            if (callbackContext != null) {
                callbackContext.success(result);
                callbackContext = null;
            }
        }
    }

    private int getIdentifier(String name) {
        final Activity activity = cordova.getActivity();
        return activity.getResources().getIdentifier(name, ANIM_CONSTANT_KEY, activity.getPackageName());
    }
}
