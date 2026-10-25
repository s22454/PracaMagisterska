require('dotenv').config()
const { remote } = require('webdriverio');
const browserstack = require('browserstack-local');
const fs = require('fs');
const path = require('path');

const bs_local = new browserstack.Local();

const USERNAME = process.env.BS_USERNAME;
const ACCESS_KEY = process.env.BS_ACCESS_KEY;
const BUILD = process.env.BS_BUILD_PWA_ANDROID

const EMAIL = process.env.APP_EMAIL;
const PASSWORD = process.env.APP_PASSWORD;

const capabilities = {
    "platformName": "android",
    "appium:platformVersion": "16.0",
    "appium:deviceName": "Google Pixel 9",
    "appium:app": BUILD,
    "bstack:options": {
        "userName": USERNAME,
        "accessKey": ACCESS_KEY,
        "appProfiling": true,
        "local": "true",
        "projectName": "Praca Magisterska",
        "buildName": "Testy Wydajnościowe Angular",
    }
};

const localArgs = {
    'key': ACCESS_KEY
};

const resultsDir = path.join(__dirname, 'measurements_json');
if (!fs.existsSync(resultsDir)) {
    fs.mkdirSync(resultsDir, { recursive: true });
}

bs_local.start(localArgs, async function() {
    console.log("Tunel BrowserStack Local uruchomiony.");

    for (let i = 1; i <= 10; i++) {
        console.log(`--- Uruchamiam próbę nr ${i} z 10 ---`);
        let driver;
        let sessionId;

        try {
            driver = await remote({
                protocol: "https",
                hostname: "hub-cloud.browserstack.com",
                port: 443,
                path: "/wd/hub",
                capabilities: capabilities
            });

            sessionId = driver.sessionId;
            console.log(`Sesja ${i} utworzona, ID: ${sessionId}`);

            await driver.waitUntil(async () => {
                const contexts = await driver.getContexts();
                return contexts.length > 1;
            }, { timeout: 10000, timeoutMsg: 'Nie wykryto kontekstu WebView' });

            const contexts = await driver.getContexts();
            const webViewContext = contexts.find(c => c.includes('WEBVIEW'));
            if (webViewContext) {
                await driver.switchContext(webViewContext);
            }

            const emailField = await driver.$('input[formcontrolname="email"], input[type="email"]');
            await emailField.waitForExist({ timeout: 20000 });
            await emailField.click();
            await driver.pause(500);

            await emailField.setValue(EMAIL);

            const passwordField = await driver.$('input[formcontrolname="password"], input[type="password"]');
            await passwordField.click();
            await driver.pause(500);
            await passwordField.setValue(PASSWORD);

            const loginBtn = await driver.$('button[type="submit"], ion-button');
            await loginBtn.click();

            const homeScreenText = await driver.$('div.home-container h1');
            await homeScreenText.waitForDisplayed({ timeout: 15000 });
            console.log(`Próba nr ${i} zakończona sukcesem!`);

        } catch (error) {
            console.error(`Błąd w próbie nr ${i}:`, error.message);
        } finally {
            if (driver) {
                try {
                    const nativeContexts = await driver.getContexts();
                    if (nativeContexts.length > 0) {
                        await driver.switchContext(nativeContexts[0]);
                    }
                } catch (e) {}

                await driver.deleteSession();
            }

            if (sessionId) {
                const filePath = path.join(resultsDir, `session-${i}-${sessionId}.json`);
                const placeholderData = {
                    trial: i,
                    session_id: sessionId,
                    status: "Manual download from BrowserStack dashboard",
                    aggregated: {},
                    report: {}
                };
                fs.writeFileSync(filePath, JSON.stringify(placeholderData, null, 2));
                console.log(`Utworzono plik: ${filePath}`);
            }
        }
    }

    bs_local.stop(function() {
        console.log("Testy zakończone, tunel zamknięty.");
    });
});
