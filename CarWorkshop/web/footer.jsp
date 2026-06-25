<script>
const d = document.getElementById('dateDisplay');
if(d) d.textContent = new Date().toLocaleDateString('en-MY', {
    weekday:'short', day:'numeric', month:'long', year:'numeric'
});
</script>
</body>
</html>