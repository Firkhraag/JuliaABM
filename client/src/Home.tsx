import { useState } from 'react'
import httpClient from './axios'
import './Home.css'

const Home = () => {
    const [image, setImage] = useState("")

    const [d, setD] = useState("0.2")

    const [s1, setS1] = useState("2.0")
    const [s2, setS2] = useState("2.0")
    const [s3, setS3] = useState("3.0")
    const [s4, setS4] = useState("4.0")
    const [s5, setS5] = useState("3.0")
    const [s6, setS6] = useState("3.0")
    const [s7, setS7] = useState("3.0")

    const [t1, setT1] = useState("0.9")
    const [t2, setT2] = useState("0.9")
    const [t3, setT3] = useState("0.1")
    const [t4, setT4] = useState("0.5")
    const [t5, setT5] = useState("0.1")
    const [t6, setT6] = useState("0.1")
    const [t7, setT7] = useState("0.3")

    const [r1, setR1] = useState("160")
    const [r2, setR2] = useState("160")
    const [r3, setR3] = useState("50")
    const [r4, setR4] = useState("80")
    const [r5, setR5] = useState("120")
    const [r6, setR6] = useState("120")
    const [r7, setR7] = useState("120")

    const [p1, setP1] = useState("0.001")
    const [p2, setP2] = useState("0.0001")
    const [p3, setP3] = useState("0.00001")
    const [p4, setP4] = useState("0.000001")

    const [isGlobalWarming, setGlobalWarming] = useState(false)
    const [isQuarantine, setQuarantine] = useState(false)

    const [globalWarmingTemperature, setGlobalWarmingTemperature] = useState("1.0")
    const [threshold, setThreshold] = useState("0.2")
    const [quarantineDays, setQuarantineDays] = useState("7")

    const getResults = () => {
        httpClient.post('/results', {
            d: d,
            s: [s1, s2, s3, s4, s5, s6, s7],
            t: [t1, t2, t3, t4, t5, t6, t7],
            r: [r1, r2, r3, r4, r5, r6, r7],
            p: [p1, p2, p3, p4],
        },
        {
            responseType: "arraybuffer"
        })
        .then((response) => {
            const base64 = btoa(
                new Uint8Array(response.data).reduce(
                    (data, byte) => data + String.fromCharCode(byte),
                    ''
                )
            )
            setImage(base64)
        })
        .catch((error) => console.log(error))
    }

    const handleGlobalWarmingChange = () => {
        setGlobalWarming(!isGlobalWarming)
    }

    const handleQuarantineChange = () => {
        setQuarantine(!isQuarantine)
    }

    return (
        <div className='container margin-cnt'>
            <h1>ABM-ARI</h1>
            <h2 className="margin-from-prev-smaller">Параметры модели</h2>
            <div className='flex margin-from-prev-smaller'>
                <div className='flex-v'>
                    <label htmlFor='d'>d</label>
                    <input 
                        className='input-cnt'
                        name='d'
                        id='d'
                        value={d}
                        onChange={(v: React.FormEvent<HTMLInputElement>) => setD(v.currentTarget.value)} />
                </div>
                <div className='flex-v'>
                    <div className='flex-v'>
                        <label htmlFor='s1'>s1 (FluA)</label>
                        <input 
                            className='input-cnt'
                            name='s1'
                            id='s1'
                            value={s1}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setS1(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='s2'>s2 (FluB)</label>
                        <input 
                            className='input-cnt'
                            name='s2'
                            id='s2'
                            value={s2}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setS2(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='s3'>s3 (RV)</label>
                        <input 
                            className='input-cnt'
                            name='s3'
                            id='s3'
                            value={s3}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setS3(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='s4'>s4 (RSV)</label>
                        <input 
                            className='input-cnt'
                            name='s4'
                            id='s4'
                            value={s4}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setS4(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='s5'>s5 (AdV)</label>
                        <input 
                            className='input-cnt'
                            name='s5'
                            id='s5'
                            value={s5}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setS5(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='s6'>s6 (PIV)</label>
                        <input 
                            className='input-cnt'
                            name='s6'
                            id='s6'
                            value={s6}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setS6(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='s7'>s7 (CoV)</label>
                        <input 
                            className='input-cnt'
                            name='s7'
                            id='s7'
                            value={s7}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setS7(v.currentTarget.value)} />
                    </div>
                </div>

                <div className='flex-v'>
                    <div className='flex-v'>
                        <label htmlFor='t1'>t1 (FluA)</label>
                        <input 
                            className='input-cnt'
                            name='t1'
                            id='t1'
                            value={t1}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setT1(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='t2'>t2 (FluB)</label>
                        <input 
                            className='input-cnt'
                            name='t2'
                            id='t2'
                            value={t2}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setT2(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='t3'>t3 (RV)</label>
                        <input 
                            className='input-cnt'
                            name='t3'
                            id='t3'
                            value={t3}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setT3(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='t4'>t4 (RSV)</label>
                        <input 
                            className='input-cnt'
                            name='t4'
                            id='t4'
                            value={t4}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setT4(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='t5'>t5 (AdV)</label>
                        <input 
                            className='input-cnt'
                            name='t5'
                            id='t5'
                            value={t5}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setT5(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='t6'>t6 (PIV)</label>
                        <input 
                            className='input-cnt'
                            name='t6'
                            id='t6'
                            value={t6}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setT6(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='t7'>t7 (CoV)</label>
                        <input 
                            className='input-cnt'
                            name='t7'
                            id='t7'
                            value={t7}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setT7(v.currentTarget.value)} />
                    </div>
                </div>

                <div className='flex-v'>
                    <div className='flex-v'>
                        <label htmlFor='r1'>r1 (FluA)</label>
                        <input 
                            className='input-cnt'
                            name='r1'
                            id='r1'
                            value={r1}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setR1(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='r2'>r2 (FluB)</label>
                        <input 
                            className='input-cnt'
                            name='r2'
                            id='r2'
                            value={r2}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setR2(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='r3'>r3 (RV)</label>
                        <input 
                            className='input-cnt'
                            name='r3'
                            id='r3'
                            value={r3}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setR3(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='r4'>r4 (RSV)</label>
                        <input 
                            className='input-cnt'
                            name='r4'
                            id='r4'
                            value={r4}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setR4(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='r5'>r5 (AdV)</label>
                        <input 
                            className='input-cnt'
                            name='r5'
                            id='r5'
                            value={r5}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setR5(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='r6'>r6 (PIV)</label>
                        <input 
                            className='input-cnt'
                            name='r6'
                            id='r6'
                            value={r6}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setR6(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='r7'>r7 (CoV)</label>
                        <input 
                            className='input-cnt'
                            name='r7'
                            id='r7'
                            value={r7}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setR7(v.currentTarget.value)} />
                    </div>
                </div>

                <div className='flex-v'>
                    <div className='flex-v'>
                        <label htmlFor='p1'>p1 (0-2)</label>
                        <input 
                            className='input-cnt'
                            name='p1'
                            id='p1'
                            value={p1}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setP1(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='p2'>p2 (3-6)</label>
                        <input 
                            className='input-cnt'
                            name='p2'
                            id='p2'
                            value={p2}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setP2(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='p3'>p3 (7-14)</label>
                        <input 
                            className='input-cnt'
                            name='p3'
                            id='p3'
                            value={p3}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setP3(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='p4'>p4 (15+)</label>
                        <input 
                            className='input-cnt'
                            name='p4'
                            id='p4'
                            value={p4}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setP4(v.currentTarget.value)} />
                    </div>
                </div>
            </div>

            <h2 className="margin-from-prev-smaller">Сценарии</h2>
            <div className='flex margin-from-prev-smaller'>
                <div className='flex-v'>
                    <div className="radio">
                        <label className='pointer'>
                            <input type="radio" name="global-warming" checked={!isGlobalWarming} onChange={ handleGlobalWarmingChange } />
                            Без глобального потепления
                        </label>
                    </div>
                    <div className="radio">
                        <label className='pointer'>
                            <input type="radio" name="global-warming" checked={isGlobalWarming} onChange={ handleGlobalWarmingChange } />
                            С глобальным потеплением
                        </label>
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='globalWarmingTemperature'>Температура</label>
                        <input 
                            className='input-cnt'
                            name='globalWarmingTemperature'
                            id='globalWarmingTemperature'
                            value={globalWarmingTemperature}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setGlobalWarmingTemperature(v.currentTarget.value)} />
                    </div>
                </div>
                <div className='flex-v'>
                    <div className="radio">
                        <label className='pointer'>
                            <input type="radio" name="school-quarantine" checked={!isQuarantine} onChange={ handleQuarantineChange } />
                            Без введения карантина в школах
                        </label>
                    </div>
                    <div className="radio">
                        <label className='pointer'>
                            <input type="radio" name="school-quarantine" checked={isQuarantine} onChange={ handleQuarantineChange } />
                            С введением карантина в школах
                        </label>
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='threshold'>Порог закрытия</label>
                        <input 
                            className='input-cnt'
                            name='threshold'
                            id='threshold'
                            value={threshold}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setThreshold(v.currentTarget.value)} />
                    </div>
                    <div className='flex-v'>
                        <label htmlFor='quarantineDays'>Число дней</label>
                        <input 
                            className='input-cnt'
                            name='quarantineDays'
                            id='quarantineDays'
                            value={quarantineDays}
                            onChange={(v: React.FormEvent<HTMLInputElement>) => setQuarantineDays(v.currentTarget.value)} />
                    </div>
                </div>
            </div>

            <div className='flex'>
                <button className='button-cnt'
                    onClick={() => getResults()}>Запуск</button>
            </div>
            {image == "" ? null : <img src={`data:;base64,${image}`} />}
		</div>
    )
}

export default Home