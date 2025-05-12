import React, { useEffect, useState } from 'react';
import {
  BarChart, Bar, CartesianGrid, XAxis, YAxis, Tooltip, Legend, ResponsiveContainer
} from 'recharts';

function FinanceChart() {
  const [data, setData] = useState([]);
  const [filterRule, setFilterRule] = useState("OB");
  const [multiMarket, setMultiMarket] = useState("none");
  const [startTime, setStartTime] = useState("");
  const [endTime, setEndTime] = useState("");
  const [date, setDate] = useState("");

  const fetchData = () => {
    const params = new URLSearchParams({
      filter_rule: filterRule,
      multi_market: multiMarket,
    });

    if (startTime) params.append("start_time", startTime);
    if (endTime) params.append("end_time", endTime);
    if (date) {
      const formattedDate = date.replace(/-/g, '/'); // convert YYYY-MM-DD to YYYY/MM/DD
      params.append("date", formattedDate);
    }

    const url = `http://localhost:8000/interval-data?${params.toString()}`;
    console.log("Fetching from:", url);

    fetch(url)
      .then(res => res.json())
      .then(json => {
        if (!json.success) {
          console.error("Eroare la încărcarea datelor:", json.error);
          return;
        }

        const raw = json.data;

        const transformed = raw.sym.map((symbol, index) => ({
          sym: symbol,
          vwap: raw.vwap[index],
          maxbid: raw.maxbid[index],
          minask: raw.minask[index],
          lastmidprice: raw.lastmidprice[index],
          volume: raw.volume[index] / 10000, // scale for display
          range: raw.range[index],
        }));

        setData(transformed);
      })
      .catch(err => console.error("Fetch failed:", err));
  };

  useEffect(() => {
    fetchData();
  }, [filterRule, multiMarket, startTime, endTime, date]);

  return (
    <div style={{ width: '100%', padding: '1rem' }}>
      <h2>Indicators per Simbol</h2>

      <form
        onSubmit={e => {
          e.preventDefault();
          fetchData();
        }}
        style={{ marginBottom: '1rem', display: 'flex', flexWrap: 'wrap', gap: '1rem' }}
      >
        <label>
          Filter Rule:
          <select value={filterRule} onChange={e => setFilterRule(e.target.value)}>
            <option value="OB">OB</option>
            <option value="TM">TM</option>
            <option value="DRK">DRK</option>
          </select>
        </label>

        <label>
          Multi-Market:
          <select value={multiMarket} onChange={e => setMultiMarket(e.target.value)}>
            <option value="none">None</option>
            <option value="multi">Multi</option>
          </select>
        </label>

        <label>
          Start Time:
          <input type="text" value={startTime} onChange={e => setStartTime(e.target.value)} placeholder="e.g. 09:00:00" />
        </label>

        <label>
          End Time:
          <input type="text" value={endTime} onChange={e => setEndTime(e.target.value)} placeholder="e.g. 10:00:00" />
        </label>

        <label>
          Date:
          <input type="date" value={date} onChange={e => setDate(e.target.value)} />
        </label>

      </form>

      <div style={{ width: '100%', height: 500 }}>
        <ResponsiveContainer>
          <BarChart data={data}>
            <CartesianGrid stroke="#ccc" />
            <XAxis dataKey="sym" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Bar dataKey="vwap" fill="#8884d8" name="VWAP" />
            <Bar dataKey="maxbid" fill="#82ca9d" name="Max Bid" />
            <Bar dataKey="minask" fill="#ff7300" name="Min Ask" />
            <Bar dataKey="lastmidprice" fill="#413ea0" name="Last Mid Price" />
            <Bar dataKey="volume" fill="#0088FE" name="Volume(10k)" />
            <Bar dataKey="range" fill="#00C49F" name="Range" />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

export default FinanceChart;
