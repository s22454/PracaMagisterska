require('dotenv').config()
const { remote } = require('webdriverio');
const browserstack = require('browserstack-local');
const fs = require('fs');
const path = require('path');

const bs_local = new browserstack.Local();

const USERNAME = process.env.BS_USERNAME;
const ACCESS_KEY = process.env.BS_ACCESS_KEY;
const BUILD = process.env.BS_BUILD

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
        "buildName": "Flutter performance tests",
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

    for (let i = 1; i <= 1; i++) {
        console.log(`--- Starting test ${i} of 10 ---`);
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

            // 1. E-mail
            const emailField = await driver.$('//*[@text="e-mail..."]');
            await emailField.waitForExist({ timeout: 20000 });
            await emailField.setValue(EMAIL);

            if (await driver.isKeyboardShown()) {
                await driver.hideKeyboard();
                await driver.pause(500);
            }

            // 2. Password
            const passwordField = await driver.$('//*[@text="password..."]');
            await passwordField.setValue(PASSWORD);

            if (await driver.isKeyboardShown()) {
                await driver.hideKeyboard();
                await driver.pause(500);
            }

            // 3. Sign in
            const loginBtn = await driver.$('~login_button');
            await loginBtn.click();

            // 4. Home verify
            const homeScreen = await driver.$('~home_screen');
            await homeScreen.waitForDisplayed({ timeout: 15000 });
            console.log(`Trial ${i} finished successfully!`);

        } catch (error) {
            console.error(`Error in trial ${i}:`, error.message);
        } finally {
            if (driver) {
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
                console.log(`Created file: ${filePath}`);
            }
        }
    }

    bs_local.stop(function() {
        console.log("Test aborted, api error");
    });
});
