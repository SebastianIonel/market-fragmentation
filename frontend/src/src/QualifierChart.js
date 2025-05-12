import React, { useEffect, useState } from 'react';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend
} from 'recharts';

function QualifierChart() {
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
    if (date) params.append("date", date.replace(/-/g, '/')); // format YYYY/MM/DD

    fetch(`http://localhost:8000/qualifiers-amount?${params.toString()}`)
      .then(res => res.json())
      .then(json => {
        if (!json.success) {
          console.error("Error fetching data:", json.error);
          return;
        }

        const raw = json.data;
        const transformed = raw.qualifier.map((q, i) => ({
          qualifier: q[0],    // unwrap from ['A'] to 'A'
          amount: raw.amount[i]
        }));

        setData(transformed);
      })
      .catch(err => console.error("Fetch error:", err));
  };

  useEffect(() => {
    fetchData();
  }, [filterRule, multiMarket, startTime, endTime, date]);

  return (
    <div style={{ width: '100%', padding: '1rem' }}>
      <h2>Tranzactions per qualifier</h2>

      <form
        onSubmit={e => {
          e.preventDefault();
          fetchData();
        }}
        style={{ marginBottom: '1rem', display: 'flex', gap: '1rem', flexWrap: 'wrap' }}
      >
        

        <label>
          Start Time:
          <input type="text" value={startTime} onChange={e => setStartTime(e.target.value)} placeholder="HH:MM" />
        </label>

        <label>
          End Time:
          <input type="text" value={endTime} onChange={e => setEndTime(e.target.value)} placeholder="HH:MM" />
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
            <XAxis dataKey="qualifier" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Bar dataKey="amount" fill="#8884d8" name="Amount" />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

export default QualifierChart;
