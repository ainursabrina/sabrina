<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Register — AutoCare Workshop</title>
  <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@400;600;700;800&family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet"/>
  <style>
    :root {
      --primary:  #6b1f1f;
      --primary2: #8a2828;
      --accent:   #e8a87c;
      --accent2:  #f0c09a;
      --bg:       #f9f5f0;
      --surface:  #ffffff;
      --surface2: #fdf8f3;
      --border:   #ede5da;
      --text:     #2c1810;
      --muted:    #8a7060;
      --red:      #c0392b;
      --green:    #2d7a4f;
    }

    * { margin:0; padding:0; box-sizing:border-box; }

    body {
    background: url('<%=request.getContextPath()%>/img/m2.jpg') center/cover no-repeat fixed;
    color: var(--text);
    font-family: 'DM Sans', sans-serif;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 32px 24px;
    position: relative;
    overflow: hidden;
  }

    body::before {
      content: '';
      position: fixed; inset: 0;
      background-image:
        linear-gradient(rgba(107,31,31,0.03) 1px, transparent 1px),
        linear-gradient(90deg, rgba(107,31,31,0.03) 1px, transparent 1px);
      background-size: 48px 48px;
      pointer-events: none;
    }

    .blob {
      position: fixed; border-radius: 50%;
      pointer-events: none; filter: blur(60px);
    }
    .blob-1 { top:-80px; left:-80px; width:320px; height:320px; background:rgba(107,31,31,0.07); }
    .blob-2 { bottom:-80px; right:-60px; width:280px; height:280px; background:rgba(232,168,124,0.09); }

    .wrapper {
      position: relative; z-index: 1;
      width: 100%; max-width: 500px;
      animation: fadeUp 0.45s ease;
    }

    @keyframes fadeUp {
      from { opacity:0; transform:translateY(18px); }
      to   { opacity:1; transform:translateY(0); }
    }

    /* ===== LOGO ===== */
    .logo-section { text-align:center; margin-bottom:28px; }

    .logo-mark {
      width:52px; height:52px;
      background: var(--primary);
      border-radius:14px;
      display:flex; align-items:center; justify-content:center;
      margin:0 auto 10px; font-size:24px;
      box-shadow: 0 8px 20px rgba(107,31,31,0.2);
    }
    
    .logo-mark img {
        width: 80px; 
        height: auto;
        display: block;
        background: transparent;
    }

    .logo-name {
      font-family:'Barlow Condensed',sans-serif;
      font-size:28px; font-weight:800; 
      color:#e8a87c;
      letter-spacing: 0.5px;
    }

    .logo-name span { color:#e8a87c; }
    .logo-sub { 
        font-size:12px; 
        color:#e8a87c;
        margin-top:3px; 
        letter-spacing: 0.5px;
    }

    /* ===== CARD ===== */
    .card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 20px;
      padding: 32px;
      box-shadow: 0 8px 32px rgba(107,31,31,0.08);
    }

    .card-title {
      font-family:'Barlow Condensed',sans-serif;
      font-size:24px; font-weight:800;
      color: var(--primary); margin-bottom:4px;
    }

    .card-title span { color:var(--accent); }

    .card-sub {
      font-size:13px; color:var(--muted);
      margin-bottom:24px;
    }

    /* ===== FORM ===== */
    .form-row {
      display:grid;
      grid-template-columns:1fr 1fr;
      gap:14px;
    }

    .form-group { margin-bottom:14px; }

    .form-label {
      font-size:11px; font-weight:600;
      color:var(--muted);
      text-transform:uppercase;
      letter-spacing:0.5px;
      margin-bottom:6px;
      display:block;
    }

    .form-input {
      width:100%;
      padding:11px 14px;
      background:var(--surface2);
      border:1px solid var(--border);
      border-radius:10px;
      color:var(--text);
      font-size:14px;
      font-family:'DM Sans',sans-serif;
      outline:none;
      transition:border-color .2s, box-shadow .2s;
    }

    .form-input:focus {
      border-color:var(--accent);
      box-shadow:0 0 0 3px rgba(232,168,124,0.15);
    }

    .form-input::placeholder { color:var(--muted); }

    /* ===== SECTION DIVIDER ===== */
    .section-label {
      font-size:11px; font-weight:700;
      text-transform:uppercase; letter-spacing:1px;
      color:var(--primary);
      padding:10px 0 6px;
      border-bottom:1px solid var(--border);
      margin-bottom:14px;
    }

    /* ===== PASSWORD STRENGTH ===== */
    .pw-strength {
      display:flex; gap:4px; margin-top:6px;
    }

    .pw-bar {
      flex:1; height:3px; border-radius:2px;
      background:var(--border); transition:.3s;
    }

    .pw-label {
      font-size:11px; color:var(--muted);
      margin-top:4px;
    }

    /* ===== BUTTONS ===== */
    .btn-row { display:flex; gap:10px; margin-top:6px; }

    .btn {
      padding:12px; border-radius:10px;
      font-weight:600; border:none; cursor:pointer;
      font-size:14px; font-family:'DM Sans',sans-serif;
      transition:.2s; flex:1; text-align:center;
      text-decoration:none; display:block;
    }

    .btn-primary { background:var(--primary); color:#fff; }
    .btn-primary:hover { background:var(--primary2); transform:translateY(-1px); }

    .btn-outline {
      background:transparent;
      border:1px solid var(--border);
      color:var(--muted);
    }
    .btn-outline:hover { border-color:var(--primary); color:var(--primary); background:#fdf0e8; }

    /* ===== ERROR ===== */
    .error-msg {
      background:#fde8e8;
      border:1px solid #f5c0c0;
      border-radius:8px;
      padding:10px 14px;
      font-size:13px;
      color:var(--red);
      margin-bottom:16px;
    }

    /* ===== SUCCESS ===== */
    .success-msg {
      background:#e8f5ee;
      border:1px solid #b8dfc8;
      border-radius:8px;
      padding:10px 14px;
      font-size:13px;
      color:var(--green);
      margin-bottom:16px;
    }

    /* ===== NOTE ===== */
    .note {
      font-size:12px; color:var(--muted);
      text-align:center; margin-top:16px;
      line-height:1.5;
    }

    .note a { color:var(--primary); text-decoration:none; font-weight:600; }
    .note a:hover { text-decoration:underline; }
  </style>
</head>
<body>

<div class="blob blob-1"></div>
<div class="blob blob-2"></div>

<div class="wrapper">

  <div class="logo-section">   
    <div class="logo-mark">
        <img src="img/logo.png" alt="Logo">
    </div>
    <div class="logo-name">Auto<span>Care</span></div>
    <div class="logo-sub">Workshop System</div>
  </div>
  <div class="card">
    <div class="card-title">Register <span>Account</span></div>
    <div class="card-sub">Please enter all information correctly.</div>

    <%-- Show error if any --%>
    <% if(request.getAttribute("error") != null){ %>
      <div class="error-msg">⚠ <%= request.getAttribute("error") %></div>
    <% } %>

    <% if(request.getAttribute("success") != null){ %>
      <div class="success-msg">✓ <%= request.getAttribute("success") %></div>
    <% } %>

    <form action="RegisterServlet" method="post">

      <div class="section-label">Personal Information</div>

      <div class="form-row">
        <div class="form-group">
          <label class="form-label">Full Name</label>
          <input type="text" name="fullname" class="form-input" placeholder="Ahmad bin Ali" required>
        </div>
        <div class="form-group">
          <label class="form-label">No. IC</label>
          <input type="text" name="ic" class="form-input" placeholder="990101-14-1234" required>
        </div>
      </div>

      <div class="form-group">
        <label class="form-label">Address</label>
        <input type="text" name="address" class="form-input" placeholder="No 12, Jalan Contoh, 50000 KL">
      </div>

      <div class="form-row">
        <div class="form-group">
          <label class="form-label">Phone Number</label>
          <input type="text" name="phone" class="form-input" placeholder="01X-XXXXXXX" required>
        </div>
        <div class="form-group">
          <label class="form-label">Email</label>
          <input type="email" name="email" class="form-input" placeholder="email@example.com" required>
        </div>
      </div>

      <div class="section-label">Account safety</div>

      <div class="form-group">
        <label class="form-label">Password</label>
        <input type="password" name="password" id="pwInput" class="form-input" placeholder="Min 8 characters" required oninput="checkStrength(this.value)">
        <div class="pw-strength">
          <div class="pw-bar" id="bar1"></div>
          <div class="pw-bar" id="bar2"></div>
          <div class="pw-bar" id="bar3"></div>
          <div class="pw-bar" id="bar4"></div>
        </div>
        <div class="pw-label" id="pwLabel"></div>
      </div>

      <div class="form-group">
        <label class="form-label">Confirm Password</label>
        <input type="password" name="confirmPassword" id="confirmPw" class="form-input" placeholder="Repeat password" required oninput="checkMatch()">
        <div class="pw-label" id="matchLabel"></div>
      </div>

      <div class="btn-row">
        <a href="login.jsp" class="btn btn-outline">← Back</a>
        <button type="submit" class="btn btn-primary">Register now</button>
      </div>

    </form>

    <div class="note">
      Already has account? <a href="login.jsp">Login here!</a>
    </div>

  </div>
</div>

<script>
  function checkStrength(pw) {
    const bars = [document.getElementById('bar1'), document.getElementById('bar2'),
                  document.getElementById('bar3'), document.getElementById('bar4')];
    const label = document.getElementById('pwLabel');

    let score = 0;
    if(pw.length >= 8) score++;
    if(/[A-Z]/.test(pw)) score++;
    if(/[0-9]/.test(pw)) score++;
    if(/[^A-Za-z0-9]/.test(pw)) score++;

    const colors = ['#c0392b','#e8a020','#2a5298','#2d7a4f'];
    const labels = ['Low','Medium','Strong','Very Strong'];

    bars.forEach((b,i) => {
      b.style.background = i < score ? colors[score-1] : 'var(--border)';
    });

    label.textContent = pw.length > 0 ? labels[score-1] || '' : '';
    label.style.color = score > 0 ? colors[score-1] : 'var(--muted)';
  }

  function checkMatch() {
    const pw = document.getElementById('pwInput').value;
    const confirm = document.getElementById('confirmPw').value;
    const label = document.getElementById('matchLabel');
    if(confirm.length === 0) { label.textContent = ''; return; }
    if(pw === confirm) {
      label.textContent = '✓ Password matched';
      label.style.color = 'var(--green)';
    } else {
      label.textContent = '✗ Password doesnt match';
      label.style.color = 'var(--red)';
    }
  }
</script>
</body>
</html>
