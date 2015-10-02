package com.mirasense.demos;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.OnSharedPreferenceChangeListener;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.preference.EditTextPreference;
import android.preference.ListPreference;
import android.preference.Preference;
import android.preference.PreferenceActivity;
import android.preference.PreferenceCategory;
import android.preference.PreferenceManager;

import com.mirasense.scanditsdk.ScanditSDKScanSettings;
import com.mirasense.scanditsdk.interfaces.ScanditSDK;
import com.mirasense.scanditsdk.interfaces.ScanditSDKOverlay;
import com.mirasense.scanditsdkdemo.R;
import com.scandit.base.camera.SbDeviceProfile;
import com.scandit.base.system.SbSystemUtils;

public class SettingsActivity extends PreferenceActivity implements OnSharedPreferenceChangeListener {
	
	@SuppressWarnings("deprecation")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		if (Build.VERSION.SDK_INT >= 14) {
			super.setTheme(android.R.style.Theme_DeviceDefault);
		} else if (Build.VERSION.SDK_INT >= 11) {
			super.setTheme(android.R.style.Theme_Holo);
		} else {
			super.setTheme(android.R.style.Theme_Black_NoTitleBar);
		}
		
		addPreferencesFromResource(R.xml.preferences);
		
		// Loop over the categories.
		for (int i = 0; i < getPreferenceScreen().getPreferenceCount(); i++) {
			Preference categoryPref = getPreferenceScreen().getPreference(i);
			if (categoryPref instanceof PreferenceCategory) {
				PreferenceCategory category = (PreferenceCategory) categoryPref;
				// Loop over the preferences inside a category.
				for (int j = 0; j < category.getPreferenceCount(); j++) {
					Preference preference = category.getPreference(j);
				    if (preference instanceof ListPreference) {
				        updateListPreference((ListPreference) preference);
				    } else if (preference instanceof EditTextPreference) {
				    	updateEditTextPreference((EditTextPreference) preference);
				    }
				}
			}
		}
	}
	
	@SuppressWarnings("deprecation")
	void updateListPreference(ListPreference preference) {
        preference.setSummary(preference.getEntry());
        
        if (preference.getKey().equals("camera_switch_visibility")) {
        	boolean enabled = true;
        	if (preference.getValue().equals("0")) {
        		enabled = false;
        	}
        	getPreferenceScreen().findPreference("camera_switch_button_x").setEnabled(enabled);
        	getPreferenceScreen().findPreference("camera_switch_button_y").setEnabled(enabled);
        }
	}
	
	void updateEditTextPreference(EditTextPreference preference) {
        preference.setSummary(preference.getText());
	}
	
	@SuppressWarnings("deprecation")
	@Override
	protected void onResume() {
	    super.onResume();
	    getPreferenceScreen().getSharedPreferences()
	            .registerOnSharedPreferenceChangeListener(this);
	}

	@SuppressWarnings("deprecation")
	@Override
	protected void onPause() {
	    super.onPause();
	    getPreferenceScreen().getSharedPreferences()
	            .unregisterOnSharedPreferenceChangeListener(this);
	}
	
	public static void setActivityOrientation(Activity activity) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(activity);
        if (SbDeviceProfile.isGlass(Build.MODEL)) {
            // Glass somehow has problems with android:configChanges="orientation|screenSize" that
            // makes the launch of an activity in SCREEN_ORIENTATION_SENSOR wonky (flickering at
            // the beginning) and the differentiation between native portrait and landscape is
            // impossible.
            activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
	    } else if (prefs.getBoolean("rotate_enabled", false)) {
            activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR);
        } else {
            if (SbSystemUtils.getDeviceDefaultOrientation(activity) == Configuration.ORIENTATION_PORTRAIT) {
                activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
            } else {
                activity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            }
        }
	}

	@SuppressWarnings("deprecation")
	public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
		Preference preference = findPreference(key);
	    if (preference instanceof ListPreference) {
	        updateListPreference((ListPreference) preference);
	    } else if (preference instanceof EditTextPreference) {
	    	updateEditTextPreference((EditTextPreference) preference);
	    }
	}
	public static List<ScanditSDK.Symbology> getEnabledSymbologies(SharedPreferences prefs) {
		List<ScanditSDK.Symbology> enabled = new ArrayList<ScanditSDK.Symbology>();
		if (prefs.getBoolean("ean13_and_upc12_enabled", true)) {
			enabled.add(ScanditSDK.Symbology.EAN13);
			enabled.add(ScanditSDK.Symbology.UPC12);
		}
		if (prefs.getBoolean("ean8_enabled", true)) {
			enabled.add(ScanditSDK.Symbology.EAN8);
		}
		if (prefs.getBoolean("upce_enabled", true)) {
			enabled.add(ScanditSDK.Symbology.UPCE);
		}
		if (prefs.getBoolean("code39_enabled", true)) {
			enabled.add(ScanditSDK.Symbology.CODE39);
		}
		if (prefs.getBoolean("code93_enabled", false)) {
			enabled.add(ScanditSDK.Symbology.CODE93);
		}
		if (prefs.getBoolean("code128_enabled", true)) {
			enabled.add(ScanditSDK.Symbology.CODE128);
		}
		if (prefs.getBoolean("itf_enabled", true)) {
			enabled.add(ScanditSDK.Symbology.ITF);
		}
		if (prefs.getBoolean("msi_plessey_enabled", false)) {
			enabled.add(ScanditSDK.Symbology.MSI_PLESSEY);
		}
		if (prefs.getBoolean("databar_enabled", false)) {
			enabled.add(ScanditSDK.Symbology.GS1_DATABAR);
		}
		if (prefs.getBoolean("databar_expanded_enabled", false)) {
			enabled.add(ScanditSDK.Symbology.GS1_DATABAR_EXPANDED);
		}
		if (prefs.getBoolean("codabar_enabled", false)) {
			enabled.add(ScanditSDK.Symbology.CODABAR);
		}
		if (prefs.getBoolean("aztec_enabled", false)) {
			enabled.add(ScanditSDK.Symbology.AZTEC);
		}
		if (prefs.getBoolean("qr_enabled", true)) {
			enabled.add(ScanditSDK.Symbology.QR);
		}
		if (prefs.getBoolean("data_matrix_enabled", true)) {
			enabled.add(ScanditSDK.Symbology.DATAMATRIX);
		}
		if (prefs.getBoolean("pdf417_enabled", false)) {
			enabled.add(ScanditSDK.Symbology.PDF417);
		}
        if (prefs.getBoolean("two_digit_add_on_enabled", false)) {
            enabled.add(ScanditSDK.Symbology.TWO_DIGIT_ADD_ON);
        }
        if (prefs.getBoolean("five_digit_add_on_enabled", false)) {
            enabled.add(ScanditSDK.Symbology.FIVE_DIGIT_ADD_ON);
        }
		return enabled;
	}
	
	public static ScanditSDKScanSettings getSettings(Context context) {
		SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);
		ScanditSDKScanSettings settings = ScanditSDKScanSettings.getDefaultSettings();
		for (ScanditSDK.Symbology sym : getEnabledSymbologies(prefs)) {
			settings.enableSymbology(sym);
		}
        if (prefs.getBoolean("two_digit_add_on_enabled", false) ||
            prefs.getBoolean("five_digit_add_on_enabled", false)) {
           settings.setMaxNumCodesPerFrame(2);
        }
		settings.setMsiPlesseyChecksumType(getMsiPlesseyChecksumType(prefs));
		if (settings.isSymbologyEnabled(ScanditSDK.Symbology.DATAMATRIX)) {
			settings.enableMicroDataMatrix(prefs.getBoolean("micro_data_matrix_enabled", false));
			settings.enableColorInverted2dRecognition(prefs.getBoolean("inverse_recognition", false));
		}
		settings.setScanningHotSpot(prefs.getInt("hot_spot_x", 50) / 100.0f,
									prefs.getInt("hot_spot_y", 50) / 100.0f);
		settings.enableRestrictedAreaScanning(prefs.getBoolean("restrict_scanning_area", false));
		settings.setScanningHotSpotHeight(prefs.getInt("hot_spot_height", 25) / 100.0f);
		return settings;
	}

	private static int getMsiPlesseyChecksumType(SharedPreferences prefs) {
		int checksum = Integer.valueOf(prefs.getString("msi_plessey_checksum", "1"));
		int actualChecksum = ScanditSDK.CHECKSUM_MOD_10;
		if (checksum == 0) {
			actualChecksum = ScanditSDK.CHECKSUM_NONE;
		} else if (checksum == 2) {
			actualChecksum = ScanditSDK.CHECKSUM_MOD_11;
		} else if (checksum == 3) {
			actualChecksum = ScanditSDK.CHECKSUM_MOD_1010;
		} else if (checksum == 4) {
			actualChecksum = ScanditSDK.CHECKSUM_MOD_1110;
		}
		return actualChecksum;
	}

	public static void applyUISettings(Context context, ScanditSDKOverlay overlay) {
		SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);
		overlay.drawViewfinder(prefs.getBoolean("draw_viewfinder", true));
		overlay.setViewfinderDimension(
				prefs.getInt("viewfinder_width",  70) / 100.0f,
				prefs.getInt("viewfinder_height",  30) / 100.0f,
				prefs.getInt("viewfinder_landscape_width",  40) / 100.0f,
				prefs.getInt("viewfinder_landscape_height",  30) / 100.0f);

		overlay.setBeepEnabled(prefs.getBoolean("beep_enabled", true));
		overlay.setVibrateEnabled(prefs.getBoolean("vibrate_enabled", false));

		overlay.showSearchBar(prefs.getBoolean("search_bar", false));
		overlay.setSearchBarPlaceholderText(prefs.getString(
				"search_bar_placeholder", "Scan barcode or enter it here"));

		overlay.setTorchEnabled(prefs.getBoolean("torch_enabled", true));
		overlay.setTorchButtonPosition(
				prefs.getInt("torch_button_x", 5) / 100.0f,
				prefs.getInt("torch_button_y", 1) / 100.0f, 67, 33);

		int cameraSwitchVisibility = getCameraSwitchVisibility(prefs);
		overlay.setCameraSwitchVisibility(cameraSwitchVisibility);
		overlay.setCameraSwitchButtonPosition(
				prefs.getInt("camera_switch_button_x", 5) / 100.0f,
				prefs.getInt("camera_switch_button_y", 1) / 100.0f, 67, 33);
	}

	private static int getCameraSwitchVisibility(SharedPreferences prefs) {
		int val = Integer.valueOf(prefs.getString("camera_switch_visibility", "0"));
		int cameraSwitchVisibility = ScanditSDKOverlay.CAMERA_SWITCH_NEVER;
		if (val == 1) {
			cameraSwitchVisibility = ScanditSDKOverlay.CAMERA_SWITCH_ON_TABLET;
		} else if (val == 2) {
			cameraSwitchVisibility = ScanditSDKOverlay.CAMERA_SWITCH_ALWAYS;
		}
		return cameraSwitchVisibility;
	}
}
