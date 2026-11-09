// Native Node.js test runner for Firestore Security Rules using the Firestore Emulator REST API
import http from 'node:http';

const PROJECT_ID = 'skill-link-2de23';
const EMULATOR_PORT = 8080;
const BASE_URL = `http://127.0.0.1:${EMULATOR_PORT}/v1/projects/${PROJECT_ID}/databases/(default)/documents`;

function makeToken(uid, email = `${uid}@example.com`) {
  const header = Buffer.from(JSON.stringify({ alg: 'none', typ: 'JWT' })).toString('base64url');
  const payload = Buffer.from(JSON.stringify({
    iss: `https://securetoken.google.com/${PROJECT_ID}`,
    aud: PROJECT_ID,
    auth_time: Math.floor(Date.now() / 1000),
    user_id: uid,
    sub: uid,
    email: email,
    email_verified: true,
    firebase: {
      identities: { email: [email] },
      sign_in_provider: 'password'
    }
  })).toString('base64url');
  return `${header}.${payload}.`;
}

async function firestoreRequest(method, path, body = null, authUid = null) {
  const url = `${BASE_URL}${path}`;
  const headers = { 'Content-Type': 'application/json' };
  if (authUid) {
    headers['Authorization'] = `Bearer ${makeToken(authUid)}`;
  }

  const response = await fetch(url, {
    method,
    headers,
    body: body ? JSON.stringify(body) : null,
  });

  const responseData = await response.json().catch(() => ({}));
  return {
    status: response.status,
    ok: response.ok,
    data: responseData,
  };
}

async function runSecurityTests() {
  console.log('--- Starting Firestore Security Rules Verification against Local Emulator ---');
  let passed = 0;
  let failed = 0;

  async function assertRule(name, fn) {
    try {
      await fn();
      console.log(`[PASS] ${name}`);
      passed++;
    } catch (err) {
      console.error(`[FAIL] ${name}: ${err.message}`);
      failed++;
    }
  }

  // 1. Unauthenticated read of private user profile must be DENIED
  await assertRule('Unauthenticated access to users/user_alice is DENIED', async () => {
    const res = await firestoreRequest('GET', '/users/user_alice');
    if (res.status !== 403) {
      throw new Error(`Expected 403 Forbidden, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  let aliceCreatedAt;
  // 2. Authenticated user creating their own valid profile must SUCCEED
  await assertRule('Authenticated user Alice can CREATE her own profile users/user_alice', async () => {
    aliceCreatedAt = new Date().toISOString();
    const body = {
      fields: {
        uid: { stringValue: 'user_alice' },
        email: { stringValue: 'alice@example.com' },
        fullName: { stringValue: 'Alice Smith' },
        activeRole: { stringValue: 'customer' },
        roles: { arrayValue: { values: [{ stringValue: 'customer' }] } },
        accountStatus: { stringValue: 'active' },
        createdAt: { timestampValue: aliceCreatedAt },
        updatedAt: { timestampValue: aliceCreatedAt },
      },
    };
    const res = await firestoreRequest('PATCH', '/users/user_alice', body, 'user_alice');
    if (res.status !== 200) {
      throw new Error(`Expected 200 OK, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 3. Authenticated user reading their own profile must SUCCEED
  await assertRule('Authenticated user Alice can READ her own profile users/user_alice', async () => {
    const res = await firestoreRequest('GET', '/users/user_alice', null, 'user_alice');
    if (res.status !== 200) {
      throw new Error(`Expected 200 OK, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 4. User Bob reading Alice's private profile must be DENIED
  await assertRule('User Bob CANNOT read Alice private profile users/user_alice', async () => {
    const res = await firestoreRequest('GET', '/users/user_alice', null, 'user_bob');
    if (res.status !== 403) {
      throw new Error(`Expected 403 Forbidden, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 5. User Bob writing to Alice's profile must be DENIED
  await assertRule('User Bob CANNOT update Alice profile users/user_alice', async () => {
    const now = new Date().toISOString();
    const body = {
      fields: {
        uid: { stringValue: 'user_alice' },
        email: { stringValue: 'alice@example.com' },
        fullName: { stringValue: 'Hacked by Bob' },
        activeRole: { stringValue: 'customer' },
        roles: { arrayValue: { values: [{ stringValue: 'customer' }] } },
        accountStatus: { stringValue: 'active' },
        createdAt: { timestampValue: now },
        updatedAt: { timestampValue: now },
      },
    };
    const res = await firestoreRequest('PATCH', '/users/user_alice', body, 'user_bob');
    if (res.status !== 403) {
      throw new Error(`Expected 403 Forbidden, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 6. User Alice CANNOT escalate privileges to Admin
  await assertRule('User Alice CANNOT grant herself Admin role (isAdmin: true)', async () => {
    const now = new Date().toISOString();
    const body = {
      fields: {
        uid: { stringValue: 'user_alice' },
        email: { stringValue: 'alice@example.com' },
        fullName: { stringValue: 'Alice Escalated' },
        activeRole: { stringValue: 'customer' },
        roles: { arrayValue: { values: [{ stringValue: 'customer' }] } },
        accountStatus: { stringValue: 'active' },
        isAdmin: { booleanValue: true },
        createdAt: { timestampValue: now },
        updatedAt: { timestampValue: now },
      },
    };
    const res = await firestoreRequest('PATCH', '/users/user_alice', body, 'user_alice');
    if (res.status !== 403) {
      throw new Error(`Expected 403 Forbidden, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 7. User Alice CANNOT set invalid roles like ['admin']
  await assertRule('User Alice CANNOT assign forbidden roles (roles: ["admin"])', async () => {
    const now = new Date().toISOString();
    const body = {
      fields: {
        uid: { stringValue: 'user_alice' },
        email: { stringValue: 'alice@example.com' },
        fullName: { stringValue: 'Alice Admin' },
        activeRole: { stringValue: 'admin' },
        roles: { arrayValue: { values: [{ stringValue: 'admin' }] } },
        accountStatus: { stringValue: 'active' },
        createdAt: { timestampValue: now },
        updatedAt: { timestampValue: now },
      },
    };
    const res = await firestoreRequest('PATCH', '/users/user_alice', body, 'user_alice');
    if (res.status !== 403) {
      throw new Error(`Expected 403 Forbidden, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 8. User Alice CANNOT modify protected accountStatus
  await assertRule('User Alice CANNOT modify protected accountStatus on update', async () => {
    const now = new Date().toISOString();
    const body = {
      fields: {
        uid: { stringValue: 'user_alice' },
        email: { stringValue: 'alice@example.com' },
        fullName: { stringValue: 'Alice Smith' },
        activeRole: { stringValue: 'customer' },
        roles: { arrayValue: { values: [{ stringValue: 'customer' }] } },
        accountStatus: { stringValue: 'suspended' }, // Unauthorized modification
        createdAt: { timestampValue: now },
        updatedAt: { timestampValue: now },
      },
    };
    const res = await firestoreRequest('PATCH', '/users/user_alice', body, 'user_alice');
    if (res.status !== 403) {
      throw new Error(`Expected 403 Forbidden, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 9. Customer Alice CANNOT create worker profile without worker role in account
  await assertRule('Customer Alice CANNOT create workerProfile without worker role', async () => {
    const now = new Date().toISOString();
    const body = {
      fields: {
        uid: { stringValue: 'user_alice' },
        fullName: { stringValue: 'Alice Smith' },
        headline: { stringValue: 'Fake Worker' },
        category: { stringValue: 'Electrician' },
        experienceYears: { integerValue: 2 },
        city: { stringValue: 'Mumbai' },
        rate: { doubleValue: 500 },
        availability: { stringValue: 'Immediate' },
        profileStatus: { stringValue: 'completed' },
        averageRating: { doubleValue: 0.0 },
        reviewCount: { integerValue: 0 },
        createdAt: { timestampValue: now },
        updatedAt: { timestampValue: now },
      },
    };
    const res = await firestoreRequest('PATCH', '/workerProfiles/user_alice', body, 'user_alice');
    if (res.status !== 403) {
      throw new Error(`Expected 403 Forbidden, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 10. Create worker account Charlie
  await assertRule('Create verified worker Charlie account', async () => {
    const now = new Date().toISOString();
    const body = {
      fields: {
        uid: { stringValue: 'user_charlie' },
        email: { stringValue: 'charlie@example.com' },
        fullName: { stringValue: 'Charlie Electrician' },
        activeRole: { stringValue: 'worker' },
        roles: { arrayValue: { values: [{ stringValue: 'worker' }] } },
        accountStatus: { stringValue: 'active' },
        createdAt: { timestampValue: now },
        updatedAt: { timestampValue: now },
      },
    };
    const res = await firestoreRequest('PATCH', '/users/user_charlie', body, 'user_charlie');
    if (res.status !== 200) {
      throw new Error(`Expected 200 OK, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 11. Verified worker Charlie CAN create his worker profile
  await assertRule('Verified worker Charlie CAN create his worker profile', async () => {
    const now = new Date().toISOString();
    const body = {
      fields: {
        uid: { stringValue: 'user_charlie' },
        fullName: { stringValue: 'Charlie Electrician' },
        headline: { stringValue: 'Certified Master Electrician' },
        category: { stringValue: 'Electrician' },
        experienceYears: { integerValue: 8 },
        city: { stringValue: 'Mumbai' },
        rate: { doubleValue: 600 },
        availability: { stringValue: 'Immediate' },
        profileStatus: { stringValue: 'completed' },
        averageRating: { doubleValue: 0.0 },
        reviewCount: { integerValue: 0 },
        createdAt: { timestampValue: now },
        updatedAt: { timestampValue: now },
      },
    };
    const res = await firestoreRequest('PATCH', '/workerProfiles/user_charlie', body, 'user_charlie');
    if (res.status !== 200) {
      throw new Error(`Expected 200 OK, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 12. Worker Charlie CANNOT manipulate rating directly
  await assertRule('Worker Charlie CANNOT fabricate his rating or review count', async () => {
    const now = new Date().toISOString();
    const body = {
      fields: {
        uid: { stringValue: 'user_charlie' },
        fullName: { stringValue: 'Charlie Electrician' },
        headline: { stringValue: 'Certified Master Electrician' },
        category: { stringValue: 'Electrician' },
        experienceYears: { integerValue: 8 },
        city: { stringValue: 'Mumbai' },
        rate: { doubleValue: 600 },
        availability: { stringValue: 'Immediate' },
        profileStatus: { stringValue: 'completed' },
        averageRating: { doubleValue: 5.0 }, // Attempt to manipulate rating!
        reviewCount: { integerValue: 99 },
        createdAt: { timestampValue: now },
        updatedAt: { timestampValue: now },
      },
    };
    const res = await firestoreRequest('PATCH', '/workerProfiles/user_charlie', body, 'user_charlie');
    if (res.status !== 403) {
      throw new Error(`Expected 403 Forbidden, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 13. Create verified worker Dan account
  await assertRule('Create verified worker Dan account', async () => {
    const now = new Date().toISOString();
    const body = {
      fields: {
        uid: { stringValue: 'user_dan' },
        email: { stringValue: 'dan@example.com' },
        fullName: { stringValue: 'Dan Plumber' },
        activeRole: { stringValue: 'worker' },
        roles: { arrayValue: { values: [{ stringValue: 'worker' }] } },
        accountStatus: { stringValue: 'active' },
        createdAt: { timestampValue: now },
        updatedAt: { timestampValue: now },
      },
    };
    const res = await firestoreRequest('PATCH', '/users/user_dan', body, 'user_dan');
    if (res.status !== 200) {
      throw new Error(`Expected 200 OK, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 14. Initial worker profile creation with rating 5.0 (the onboarding bug) MUST BE DENIED
  await assertRule('Worker Dan initial profile creation with averageRating: 5.0 is DENIED', async () => {
    const now = new Date().toISOString();
    const body = {
      fields: {
        uid: { stringValue: 'user_dan' },
        fullName: { stringValue: 'Dan Plumber' },
        headline: { stringValue: 'Expert Plumber' },
        category: { stringValue: 'Plumber' },
        experienceYears: { integerValue: 5 },
        city: { stringValue: 'Delhi' },
        rate: { doubleValue: 450 },
        availability: { stringValue: 'Immediate' },
        profileStatus: { stringValue: 'completed' },
        averageRating: { doubleValue: 5.0 }, // Rating fabrication on create!
        reviewCount: { integerValue: 0 },
        createdAt: { timestampValue: now },
        updatedAt: { timestampValue: now },
      },
    };
    const res = await firestoreRequest('PATCH', '/workerProfiles/user_dan', body, 'user_dan');
    if (res.status !== 403) {
      throw new Error(`Expected 403 Forbidden, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 15. Initial worker profile creation with rating 0.0 and reviewCount 0 SUCCEEDS
  await assertRule('Worker Dan initial profile creation with averageRating: 0.0 and reviewCount: 0 SUCCEEDS', async () => {
    const now = new Date().toISOString();
    const body = {
      fields: {
        uid: { stringValue: 'user_dan' },
        fullName: { stringValue: 'Dan Plumber' },
        headline: { stringValue: 'Expert Plumber' },
        category: { stringValue: 'Plumber' },
        experienceYears: { integerValue: 5 },
        city: { stringValue: 'Delhi' },
        rate: { doubleValue: 450 },
        availability: { stringValue: 'Immediate' },
        profileStatus: { stringValue: 'completed' },
        averageRating: { doubleValue: 0.0 },
        reviewCount: { integerValue: 0 },
        createdAt: { timestampValue: now },
        updatedAt: { timestampValue: now },
      },
    };
    const res = await firestoreRequest('PATCH', '/workerProfiles/user_dan', body, 'user_dan');
    if (res.status !== 200) {
      throw new Error(`Expected 200 OK, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 16. Customer Alice enrolls as worker (adds worker role to existing customer account)
  await assertRule('Customer Alice can enroll in worker capability', async () => {
    const now = new Date().toISOString();
    const body = {
      fields: {
        uid: { stringValue: 'user_alice' },
        email: { stringValue: 'alice@example.com' },
        fullName: { stringValue: 'Alice Smith' },
        activeRole: { stringValue: 'worker' },
        roles: { arrayValue: { values: [{ stringValue: 'customer' }, { stringValue: 'worker' }] } },
        accountStatus: { stringValue: 'active' },
        createdAt: { timestampValue: aliceCreatedAt },
        updatedAt: { timestampValue: now },
      },
    };
    const res = await firestoreRequest('PATCH', '/users/user_alice', body, 'user_alice');
    if (res.status !== 200) {
      throw new Error(`Expected 200 OK, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 17. Now enrolled Alice CAN publish her worker profile
  await assertRule('Enrolled Alice CAN publish worker profile with averageRating: 0.0', async () => {
    const now = new Date().toISOString();
    const body = {
      fields: {
        uid: { stringValue: 'user_alice' },
        fullName: { stringValue: 'Alice Smith' },
        headline: { stringValue: 'Now a Verified Painter' },
        category: { stringValue: 'Painter' },
        experienceYears: { integerValue: 3 },
        city: { stringValue: 'Mumbai' },
        rate: { doubleValue: 350 },
        availability: { stringValue: 'Immediate' },
        profileStatus: { stringValue: 'completed' },
        averageRating: { doubleValue: 0.0 },
        reviewCount: { integerValue: 0 },
        createdAt: { timestampValue: now },
        updatedAt: { timestampValue: now },
      },
    };
    const res = await firestoreRequest('PATCH', '/workerProfiles/user_alice', body, 'user_alice');
    if (res.status !== 200) {
      throw new Error(`Expected 200 OK, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 18. Worker Charlie updating his profile while preserving rating & review count SUCCEEDS
  await assertRule('Worker Charlie can update his profile while preserving rating & reviewCount', async () => {
    const now = new Date().toISOString();
    const body = {
      fields: {
        uid: { stringValue: 'user_charlie' },
        fullName: { stringValue: 'Charlie Electrician' },
        headline: { stringValue: 'Updated Headline Master Electrician' },
        category: { stringValue: 'Electrician' },
        experienceYears: { integerValue: 9 },
        city: { stringValue: 'Pune' },
        rate: { doubleValue: 700 },
        availability: { stringValue: 'Immediate' },
        profileStatus: { stringValue: 'completed' },
        averageRating: { doubleValue: 0.0 }, // Preserves original rating
        reviewCount: { integerValue: 0 },     // Preserves original count
        createdAt: { timestampValue: now },
        updatedAt: { timestampValue: now },
      },
    };
    const res = await firestoreRequest('PATCH', '/workerProfiles/user_charlie', body, 'user_charlie');
    if (res.status !== 200) {
      throw new Error(`Expected 200 OK, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 8. Public can read worker discovery profiles
  await assertRule('Public unauthenticated visitor CAN read worker discovery directory', async () => {
    const res = await firestoreRequest('GET', '/workerProfiles');
    if (res.status !== 200) {
      throw new Error(`Expected 200 OK, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  // 9. Unauthenticated visitor CANNOT access protected jobs collection
  await assertRule('Unauthenticated visitor CANNOT read jobs collection', async () => {
    const res = await firestoreRequest('GET', '/jobs');
    if (res.status !== 403) {
      throw new Error(`Expected 403 Forbidden, got ${res.status}: ${JSON.stringify(res.data)}`);
    }
  });

  console.log(`\nSecurity Rules Test Summary: ${passed} passed, ${failed} failed`);
  if (failed > 0) {
    process.exit(1);
  }
}

runSecurityTests().catch((err) => {
  console.error('Fatal test error:', err);
  process.exit(1);
});
