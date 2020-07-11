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

module.exports = [
    {
        mode: 'development',
        entry: "./src/login.js",
        output: {
            filename: "./login.js"
        },
        module: rules
    },
    {
        mode: 'development',
        entry: "./src/register.js",
        output: {
            filename: "./register.js"
        },
        module: rules
    },
    {
        mode: 'development',
        entry: "./src/all.js",
        output: {
            filename: "./all.js"
        },
        module: rules
    },
    {
        mode: 'development',
        entry: "./src/list.js",
        output: {
            filename: "./list.js"
        },
        module: rules
    },
];