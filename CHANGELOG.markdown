### 2.0.1 / 2011-06-17

* Bug Fixes
  * Removed Rack::ResponseSignatureRepeater
    * This removes the Response-Signature header from the application, leaving X-Response-Signature intact.

### 2.0.0 / 2011-06-17

* Enhancements
  * Upgrade to Rails 3.0.9
  * Remove VERSION file in favor of Keymaster::VERSION
  * Use postgresql in all environments (dropping sqlite3 support)
