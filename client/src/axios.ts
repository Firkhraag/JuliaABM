import axios from 'axios'

const httpClient = axios.create({
	baseURL: 'http://127.0.0.1:8000/api',
	withCredentials: false,
	timeout: 3000,
})

export default httpClient
