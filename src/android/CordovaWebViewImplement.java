package cordova.plugin.bankerise.keycloakauthentication;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ProgressBar;

import static cordova.plugin.bankerise.keycloakauthentication.SharedConstants.ACTIVATE_BACK_BUTTON_KEY;

@SuppressLint("SetJavaScriptEnabled")

public class CordovaWebViewImplement extends Activity {

    private WebView mWebView;
    private ProgressBar mProgressBar;
    private boolean mShouldBack;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(getResources().getIdentifier("cordova_webview", "layout", getPackageName()));
        mWebView = findViewById(getResources().getIdentifier("webView", "id", getPackageName()));
        mProgressBar = findViewById(getResources().getIdentifier("progressBar", "id", getPackageName()));
        WebSettings webSettings = mWebView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);
        String url = getIntent().getStringExtra("URL");
        mShouldBack = getIntent().getBooleanExtra(ACTIVATE_BACK_BUTTON_KEY, true);
        startWebView(url);
    }

    private void startWebView(String url) {

        mWebView.setWebViewClient(new WebViewClient() {

            public void onPageFinished(WebView view, String url) {
                mProgressBar.setVisibility(View.GONE);
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                if (url == null || url.startsWith("http://") || url.startsWith("https://"))
                    return false;

                try {
                    Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
                    view.getContext().startActivity(intent);
                    return true;
                } catch (Exception e) {
                    return true;
                }
            }

            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                super.onPageStarted(view, url, favicon);
                mProgressBar.setVisibility(View.VISIBLE);
            }

            @Override
            public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                super.onReceivedError(view, request, error);
                mProgressBar.setVisibility(View.GONE);
            }
        });


        mWebView.loadUrl(url);

    }

    @Override
    public void onBackPressed() {
        if(mShouldBack){
            super.onBackPressed();
        }
    }
}
