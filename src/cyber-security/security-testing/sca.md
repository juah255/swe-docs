# SCA

Software Composition Analysis (SCA) scans dependencies for known
vulnerabilities and license issues.

It relies on a software bill of materials (SBOM) that lists what is in the
software, matched against vulnerability databases such as the CVE feed and
advisory sources.

Prioritize findings by reachability: a vulnerable dependency that is actually
called in your code path matters more than one that is merely present.

Run SCA in CI on every change, and also on a schedule so new advisories are
caught even when nothing changes. Treat findings as tracked work with owners
and deadlines.

See [Vulnerability Assessment](vulnerability-assessment.md) and
[../software-supply-chain/vulnerability-scanning.md](../software-supply-chain/vulnerability-scanning.md)
for the wider supply chain picture.
