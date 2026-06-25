<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
String showStep = "role";
if(request.getAttribute("error") != null) showStep = "staff";
if(request.getAttribute("custError") != null) showStep = "customer";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Login — AutoCare Workshop</title>
  
  <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@400;600;700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;1,400&display=swap" rel="stylesheet"/>
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
      --green:    #2d7a4f;
      --blue:     #2a5298;
      --red:      #c0392b;
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

    /* subtle background pattern */
    body::before {
      content: '';
      position: fixed; 
      inset: 0;
      background-image:
        linear-gradient(rgba(107,31,31,0.03) 1px, transparent 1px),
        linear-gradient(90deg, rgba(107,31,31,0.03) 1px, transparent 1px);
      background-size: 48px 48px;
      pointer-events: none;
    }

    /* soft glow blobs */
    .blob {
      position: fixed;
      border-radius: 50%;
      pointer-events: none;
      filter: blur(60px);
    }
    .blob-1 {
      top: -100px; left: -100px;
      width: 400px; height: 400px;
      background: rgba(107,31,31,0.08);
    }
    .blob-2 {
      bottom: -100px; right: -80px;
      width: 350px; height: 350px;
      background: rgba(232,168,124,0.1);
    }

    .wrapper {
      position: relative;
      z-index: 1;
      width: 100%;
      max-width: 460px;
      animation: fadeUp 0.45s ease;
    }

    @keyframes fadeUp {
      from { opacity:0; transform:translateY(18px); }
      to   { opacity:1; transform:translateY(0); }
    }

    /* ===== LOGO ===== */
    .logo-section {
      text-align: center;
      margin-bottom: 32px;
    }

    .logo-mark {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: auto;
        height: auto;
        background: transparent;
        border-radius: 0;
        margin-bottom: 12px;
        box-shadow: none;
    }

    .logo-mark img {
        width: 80px; 
        height: auto;
        display: block;
        background: transparent;
    }

    .logo-name {
      font-family: 'Barlow Condensed', sans-serif;
      font-size: 28px; font-weight: 800;
      color: #e8a87c;
      letter-spacing: 0.5px;
    }

    .logo-name span { color: #e8a87c; }

    .logo-sub {
      font-size: 12px;
      color:#e8a87c;
      margin-top: 4px;
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

    /* ===== STEPS ===== */
    .step { display: none; }
    .step.active { display: block; }

    .step-title {
      font-family: 'Barlow Condensed', sans-serif;
      font-size: 24px; font-weight: 800;
      color: var(--primary);
      text-align: center;
      margin-bottom: 6px;
    }

    .step-title span { color: var(--accent); }

    .step-sub {
      font-size: 13px;
      color: var(--muted);
      text-align: center;
      margin-bottom: 24px;
    }

    /* ===== ROLE CARDS ===== */
    .role-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
      margin-bottom: 16px;
    }

    .role-card {
      background: var(--surface2);
      border: 2px solid var(--border);
      border-radius: 14px;
      padding: 20px 14px;
      text-align: center;
      cursor: pointer;
      transition: .2s;
      position: relative;
      overflow: hidden;
    }

    .role-card:hover {
      border-color: var(--accent);
      background: #fdf0e8;
      transform: translateY(-2px);
    }

    .role-card.selected {
      border-color: var(--primary);
      background: rgba(107,31,31,0.05);
    }

    .check {
      position: absolute; top: 9px; right: 9px;
      width: 18px; height: 18px;
      border-radius: 50%;
      background: var(--primary);
      color: white;
      display: none;
      align-items: center; justify-content: center;
      font-size: 10px; font-weight: 700;
    }

    .role-card.selected .check { display: flex; }

    .role-icon { font-size: 30px; margin-bottom: 8px; }

    .role-name {
      font-family: 'Barlow Condensed', sans-serif;
      font-size: 16px; font-weight: 700;
      color: var(--primary); margin-bottom: 4px;
    }

    .role-desc { font-size: 11px; color: var(--muted); line-height: 1.4; }

    .role-card.full {
      grid-column: 1 / -1;
      display: flex; align-items: center; gap: 14px;
      text-align: left; padding: 14px 18px;
    }

    .role-card.full .role-icon { font-size: 26px; flex-shrink: 0; margin: 0; }
    .role-card.full .role-text { flex: 1; }

    /* ===== FORM ===== */
    .form-group { margin-bottom: 16px; }

    .form-label {
      display: block;
      font-size: 11px; font-weight: 600;
      color: var(--muted);
      margin-bottom: 6px;
      letter-spacing: 0.5px;
      text-transform: uppercase;
    }

    .form-input {
      width: 100%;
      background: var(--surface2);
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 11px 14px;
      font-size: 14px;
      color: var(--text);
      font-family: 'DM Sans', sans-serif;
      outline: none;
      transition: border-color .2s, box-shadow .2s;
    }

    .form-input:focus {
      border-color: var(--accent);
      box-shadow: 0 0 0 3px rgba(232,168,124,0.15);
    }

    .form-input::placeholder { color: var(--muted); }

    /* ===== BUTTONS ===== */
    .btn {
      width: 100%; padding: 12px;
      border-radius: 10px; font-size: 14px;
      font-weight: 600; cursor: pointer; border: none;
      transition: .2s; font-family: 'DM Sans', sans-serif;
    }

    .btn-primary { background: var(--primary); color: #fff; }
    .btn-primary:hover { background: var(--primary2); transform: translateY(-1px); }
    .btn-primary:disabled { background: var(--border); color: var(--muted); cursor: not-allowed; transform: none; }

    .btn-outline {
      background: transparent;
      border: 1px solid var(--border);
      color: var(--muted);
      margin-top: 10px;
    }
    .btn-outline:hover { border-color: var(--primary); color: var(--primary); background: #fdf0e8; }

    /* ===== ERROR ===== */
    .error-msg {
      background: #fde8e8;
      border: 1px solid #f5c0c0;
      border-radius: 8px;
      padding: 10px 14px;
      font-size: 13px;
      color: var(--red);
      margin-bottom: 16px;
    }

    /* ===== PASSWORD TOGGLE ===== */
    .input-wrap { position: relative; }

    .toggle-pw {
      position: absolute; right: 12px; top: 50%;
      transform: translateY(-50%);
      cursor: pointer; font-size: 15px;
      color: var(--muted); background: none; border: none;
    }

    /* ===== ROLE TAG ===== */
    .role-tag {
      padding: 4px 14px; border-radius: 20px;
      font-size: 12px; font-weight: 600;
      width: fit-content; margin: 0 auto 20px;
      display: flex; align-items: center; gap: 6px;
    }

    /* ===== DIVIDER ===== */
    .divider {
      text-align: center;
      font-size: 12px;
      color: var(--muted);
      margin: 14px 0;
      position: relative;
    }

    .divider::before, .divider::after {
      content: '';
      position: absolute; top: 50%;
      width: 38%; height: 1px;
      background: var(--border);
    }
    
    .logo-mark img{
        width:60px;
        height:60px;
        object-fit:contain;
    }

    .divider::before { left: 0; }
    .divider::after { right: 0; }
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

    <!-- STEP 1: PILIH ROLE -->
    <div class="step active" id="step-role">
      <div class="step-title">Who are <span>you?</span></div>

      <div class="role-grid">
        <div class="role-card" onclick="selectRole('admin', this)">
          <div class="check">✓</div>
          <div class="role-icon">👨‍💼</div>
          <div class="role-name">Admin</div>
        </div>

        <div class="role-card" onclick="selectRole('mechanic', this)">
          <div class="check">✓</div>
          <div class="role-icon">🔧</div>
          <div class="role-name">Mechanic</div>
        </div>

        <div class="role-card full" onclick="goCustomer()">
          <div class="role-icon">🚗</div>
          <div class="role-text">
            <div class="role-name">Customer</div>
          </div>
          <div style="color:var(--muted)">→</div>
        </div>
      </div>

      <button class="btn btn-primary" id="nextBtn" disabled onclick="goStaffLogin()">
        Continue →
      </button>
    </div>

    <!-- STEP 2: STAFF LOGIN -->
    <div class="step" id="step-staff">
      <div class="role-tag" id="staffTag"></div>
      <div class="step-title">Staff <span>Login</span></div>

      <% if(request.getAttribute("error") != null){ %>
        <div class="error-msg">⚠ <%= request.getAttribute("error") %></div>
      <% } %>

      <form action="LoginServlet" method="post">
        <input type="hidden" name="loginType" value="staff"/>
        <input type="hidden" name="role" id="staffRole"/>

        <div class="form-group">
          <label class="form-label">Working ID</label>
          <input class="form-input" type="text" name="userId" placeholder="ADM001 / MEC001" required/>
        </div>

        <div class="form-group">
          <label class="form-label">Password</label>
          <div class="input-wrap">
            <input class="form-input" type="password" name="password" id="staffPw" placeholder="Masukkan password" style="padding-right:42px" required/>
            <button class="toggle-pw" type="button" onclick="togglePw('staffPw', this)">👁️</button>
          </div>
        </div>

        <button class="btn btn-primary" type="submit">Log In</button>
      </form>

      <button class="btn btn-outline" onclick="backToRole()">← Back</button>
    </div>

    <!-- STEP 3: CUSTOMER LOGIN -->
    <div class="step" id="step-customer">
      <div class="role-tag" style="background:rgba(45,122,79,0.1); color:var(--green);">
        🚗 Customer Login
      </div>
      <div class="step-title">Customer <span>Login</span></div>
      <div class="step-sub">Login by using email or phone number</div>

      <% if(request.getAttribute("custError") != null){ %>
        <div class="error-msg">⚠ <%= request.getAttribute("custError") %></div>
      <% } %>

      <form action="LoginServlet" method="post">
        <input type="hidden" name="loginType" value="customer"/>

        <div class="form-group">
          <label class="form-label">Email / Phone</label>
          <input class="form-input" type="text" name="emailphone" placeholder="example@email.com" required/>
        </div>

        <div class="form-group">
          <label class="form-label">Password</label>
          <div class="input-wrap">
            <input class="form-input" type="password" name="password" id="custPw" placeholder="Masukkan password" style="padding-right:42px" required/>
            <button class="toggle-pw" type="button" onclick="togglePw('custPw', this)">👁️</button>
          </div>
        </div>

        <button class="btn btn-primary" type="submit">Log In</button>
      </form>

      <div class="divider">or</div>

      <button class="btn btn-outline" onclick="window.location.href='register.jsp'">
        Register new account
      </button>

      <button class="btn btn-outline" style="margin-top:8px;" onclick="backToRole()">← Back</button>
    </div>

  </div>
</div>

<script>
  let selectedRole = null;

  function selectRole(role, el) {
    selectedRole = role;
    document.querySelectorAll('.role-card:not(.full)').forEach(c => c.classList.remove('selected'));
    el.classList.add('selected');
    document.getElementById('nextBtn').disabled = false;
    document.getElementById('staffRole').value = role;
  }
  
  function goStaffLogin() {
    document.getElementById('step-role').classList.remove('active');
    document.getElementById('step-staff').classList.add('active');
    const tag = document.getElementById('staffTag');
    if(selectedRole === 'admin') {
      tag.innerHTML = '👨‍💼 Admin Login';
      tag.style.cssText = 'background:rgba(107,31,31,0.08);color:var(--primary);';
    } else {
      tag.innerHTML = '🔧 Mechanic Login';
      tag.style.cssText = 'background:rgba(42,82,152,0.08);color:var(--blue);';
    }
    document.getElementById('staffRole').value = selectedRole || 'admin';
  }
  
  function goCustomer() {
    document.getElementById('step-role').classList.remove('active');
    document.getElementById('step-customer').classList.add('active');
  }

  function backToRole() {
    document.querySelectorAll('.step').forEach(s => s.classList.remove('active'));
    document.getElementById('step-role').classList.add('active');
  }

  function togglePw(id, btn) {
    const input = document.getElementById(id);
    if(input.type === 'password') { input.type = 'text'; btn.innerHTML = '🙈'; }
    else { input.type = 'password'; btn.innerHTML = '👁️'; }
  }

  const initStep = "<%= showStep %>";
  if(initStep === "staff") {
    document.getElementById('step-role').classList.remove('active');
    document.getElementById('step-staff').classList.add('active');
  } else if(initStep === "customer") {
    document.getElementById('step-role').classList.remove('active');
    document.getElementById('step-customer').classList.add('active');
  }
</script>
</body>
</html>
