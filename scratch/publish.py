import urllib.request
import urllib.parse
import http.cookiejar
import json

# Create a cookie jar to handle csrf cookies
cj = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))

# Get the csrf token from rentry.co homepage
req = urllib.request.Request("https://rentry.co", headers={
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)'
})

try:
    with opener.open(req) as response:
        html = response.read().decode('utf-8')
except Exception as e:
    print(json.dumps({"status": "error", "message": f"Failed to connect to Rentry homepage: {str(e)}"}))
    exit(1)

csrf_token = ""
for cookie in cj:
    if cookie.name == 'csrftoken':
        csrf_token = cookie.value
        break

if not csrf_token:
    print(json.dumps({"status": "error", "message": "CSRF token not found"}))
    exit(1)

content = """# Privacy Policy

**Last Updated: July 13, 2026**

This privacy policy governs your use of the software application **Teacher App Attendance** ("Application") created by **Smart AIG**. The Application is designed to manage teacher attendance, homework uploads, and related academic modules.

## 1. Information We Collect

The Application obtains the information you provide when you download and register the Application. Registration with us is mandatory in order to use the Application.

* **Personal Information:** We collect your registered mobile number for authentication and OTP verification.
* **Attendance Data:** We collect timestamps of your Clock-In and Clock-Out activities.
* **Location Information:** The Application may collect real-time location data to verify that attendance is marked within the school premises.
* **Device Info:** We may collect device details to ensure secure login and institutional access control.

## 2. How We Use the Information

We use the collected information to:

* Verify your identity and login session.
* Record accurate attendance logs for school administration.
* Ensure security and prevent unauthorized access to school data.

## 3. Third Party Access

We do not sell, trade, or otherwise transfer your personally identifiable information to outside parties. We may disclose User Provided and Automatically Collected Information:

* As required by law, such as to comply with a subpoena or similar legal process.
* To trusted service providers (like OTP SMS gateway) who work on our behalf to support authentication.

## 4. Data Retention and Security

We take security measures seriously. We use secure AES-256 encrypted access and institutional verified gateways to safeguard your information from unauthorized access.

## 5. Your Consent

By using the Application, you are consenting to our processing of your information as set forth in this Privacy Policy now and as amended by us.

## 6. Contact Us

If you have any questions regarding privacy while using the Application, or have questions about our practices, please contact us at:

Email: **support@smartaig.com**

***

© 2026 Smart AIG. All rights reserved.
"""

data = urllib.parse.urlencode({
    'text': content,
    'edit_code': 'smartaig123'
}).encode('utf-8')

req2 = urllib.request.Request("https://rentry.co/api/new", data=data, headers={
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
    'Referer': 'https://rentry.co',
    'X-CSRFToken': csrf_token
})

try:
    with opener.open(req2) as response2:
        resp_data = response2.read().decode('utf-8')
        print(resp_data)
except Exception as e:
    print(json.dumps({"status": "error", "message": f"Failed to publish to Rentry: {str(e)}"}))
