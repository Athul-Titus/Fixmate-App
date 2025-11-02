import React, { useState, useEffect } from "react";
import axios from "axios";

const API_BASE = "http://127.0.0.1:5000/api";

function App() {
  const [brands, setBrands] = useState([]);
  const [appliances, setAppliances] = useState([]);
  const [issues, setIssues] = useState([]);
  const [selected, setSelected] = useState({ brand: "", appliance: "", issue: "" });
  const [solution, setSolution] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    axios.get(`${API_BASE}/brands`).then(res => setBrands(res.data));
  }, []);

  const fetchAppliances = (brand) => {
    setSelected({ brand, appliance: "", issue: "" });
    setIssues([]);
    setSolution("");
    axios.get(`${API_BASE}/appliances?brand=${brand}`).then(res => setAppliances(res.data));
  };

  const fetchIssues = (appliance) => {
    setSelected(prev => ({ ...prev, appliance, issue: "" }));
    setSolution("");
    axios.get(`${API_BASE}/issues?brand=${selected.brand}&appliance=${appliance}`)
      .then(res => setIssues(res.data));
  };

  const getSolution = async () => {
    if (!selected.brand || !selected.appliance || !selected.issue) {
      setError("Please select all fields");
      return;
    }
    
    setLoading(true);
    setError("");
    
    try {
      const response = await axios.post(`${API_BASE}/solution`, selected);
      setSolution(response.data.solution);
    } catch (err) {
      setError(err.response?.data?.error || "Failed to fetch solution");
      setSolution("");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ padding: 30 }}>
      <h1>FixMate Kerala</h1>
      <label>Brand:</label>
      <select onChange={e => fetchAppliances(e.target.value)} value={selected.brand}>
        <option value="">Select</option>
        {brands.map(b => <option key={b} value={b}>{b}</option>)}
      </select>

      <br /><br />

      <label>Appliance:</label>
      <select 
        onChange={e => fetchIssues(e.target.value)} 
        value={selected.appliance}
        disabled={!selected.brand}
      >
        <option value="">Select</option>
        {appliances.map(a => <option key={a} value={a}>{a}</option>)}
      </select>

      <br /><br />

      <label>Issue:</label>
      <select 
        onChange={e => setSelected(prev => ({ ...prev, issue: e.target.value }))}
        value={selected.issue}
        disabled={!selected.appliance}
      >
        <option value="">Select</option>
        {issues.map(i => <option key={i} value={i}>{i}</option>)}
      </select>

      <br /><br />

      <button 
        onClick={getSolution} 
        disabled={!selected.brand || !selected.appliance || !selected.issue || loading}
      >
        {loading ? "Loading..." : "Find Solution"}
      </button>

      {error && (
        <div style={{ color: 'red', marginTop: 10 }}>
          {error}
        </div>
      )}

      {solution && (
        <div style={{ marginTop: 20 }}>
          <b>Solution:</b> {solution}
        </div>
      )}
    </div>
  );
}

export default App;
