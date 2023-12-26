// Global
import { BrowserRouter, Routes , Route } from "react-router-dom"
import Home from './Home'
// Local
import './App.css'

export default function App() {
	return (
        <BrowserRouter>
            <Routes>
                <Route path="/" element={<Home />} />
            </Routes>
        </BrowserRouter>
    )
}
