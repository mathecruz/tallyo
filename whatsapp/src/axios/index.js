const axios = require("axios")

const createAxios = () => {
    return axios.create({
        baseURL: process.env.TALLYO_API_URL || "http://localhost:8080",
    })
}

module.exports = createAxios()
