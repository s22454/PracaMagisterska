require('dotenv').config();
const jsonServer = require('json-server');
const server = jsonServer.create();
const router = jsonServer.router('db.json');

const middlewares = jsonServer.defaults({ static: './public' });

server.use(middlewares);
server.use(jsonServer.bodyParser);

const EMAIL = process.env.EMAIL;
const PASSWORD = process.env.PASSWORD;

server.post('/api/auth/login', (req, res) => {
    console.log(req.body);
    const { email, password } = req.body;

    if (email === EMAIL && password === PASSWORD) {

        res.status(200).json({
            token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwiaWQiOiIxMjMiLCJyb2xlIjoic3R1ZGVudCJ9.mock_signature_12345"
        });
    } else {

        res.status(401).json({
            message: "Nieprawidłowy e-mail lub hasło."
        });
    }
});


server.use(router);

server.listen(3000, () => {
    console.log('Custom Mock Server Gakko działa na porcie 3000');
});
