const path = require("path");

const rules =  {
    rules: [
        {
            test: /\.m?js$/,
            exclude: /(node_modules|bower_components)/,
            use: {
                loader: "babel-loader"
            }
        },
        {
            test: /\.css$/,
            use: [
                "style-loader",
                {
                    loader: "css-loader",
                    options: {
                        modules: true,
                        importLoaders: 1
                    }
                }
            ]
        },
        {
            test: /\.(png|svg|jpg|gif)$/,
            use: ["file-loader"]
        }
    ]
}
mode = 'development'

module.exports = [
    {
        mode: mode,
        entry: "./src/App.js",
        output: {
            filename: "./App.js"
        },
        module: rules
    },

    {
        mode: mode,
        entry: "./src/login.js",
        output: {
            filename: "./login.js"
        },
        module: rules
    },
    {
        mode: mode,
        entry: "./src/register.js",
        output: {
            filename: "./register.js"
        },
        module: rules
    },
    {
        mode: mode,
        entry: "./src/settings.js",
        output: {
            filename: "./settings.js"
        },
        module: rules
    },
];