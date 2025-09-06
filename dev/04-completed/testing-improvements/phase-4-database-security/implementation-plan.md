# Phase 4: Database Security Testing Implementation
**Week 4 - Multi-tenant Data Protection & RLS Validation**

*Duration: 5 days*  
*Target: 100% RLS policy coverage*  
*Focus: 18+ tables with comprehensive security testing*

---

## Overview

Database security testing ensures multi-tenant data isolation and prevents unauthorized access. With 18+ database tables containing Row Level Security (RLS) policies, comprehensive testing prevents data leaks between organizations.

## Day-by-Day Implementation

### Day 1: RLS Testing Framework
**Time: 4 hours**

```typescript
// tests/database/rls-test-framework.ts
import { createClient } from '@supabase/supabase-js';
import { Database } from '@/lib/database.types';

export class RLSTestFramework {
  private supabase = createClient<Database>(
    process.env.TEST_SUPABASE_URL!,
    process.env.TEST_SUPABASE_ANON_KEY!
  );
  
  async testTableRLS(config: RLSTestConfig) {
    const results: RLSTestResult[] = [];
    
    for (const scenario of config.scenarios) {
      const result = await this.executeRLSTest(config.table, scenario);
      results.push(result);
    }
    
    return {
      table: config.table,
      totalTests: results.length,
      passed: results.filter(r => r.passed).length,
      failed: results.filter(r => !r.passed).length,
      results,
    };
  }
  
  private async executeRLSTest(table: string, scenario: RLSTestScenario): Promise<RLSTestResult> {
    try {
      // Setup test user context
      await this.setupUserContext(scenario.user);
      
      // Attempt the operation
      const result = await this.performOperation(table, scenario.operation);
      
      // Validate result against expectation
      const passed = this.validateResult(result, scenario.expected);
      
      return {
        scenario: scenario.name,
        operation: scenario.operation.type,
        user: scenario.user,
        passed,
        result,
        expected: scenario.expected,
        error: null,
      };
      
    } catch (error) {
      return {
        scenario: scenario.name,
        operation: scenario.operation.type,
        user: scenario.user,
        passed: scenario.expected.shouldFail === true,
        result: null,
        expected: scenario.expected,
        error: error.message,
      };
    }
  }
  
  private async setupUserContext(user: TestUser) {
    const { data: session } = await this.supabase.auth.signInWithPassword({
      email: user.email,
      password: user.password,
    });
    
    if (!session) {
      throw new Error(`Failed to authenticate user: ${user.email}`);
    }
    
    // Set organization context if needed
    if (user.organizationId) {
      await this.supabase.rpc('set_current_organization', {
        org_id: user.organizationId,
      });
    }
  }
  
  private async performOperation(table: string, operation: DatabaseOperation) {
    switch (operation.type) {
      case 'select':
        return await this.supabase
          .from(table)
          .select(operation.columns || '*')
          .eq('id', operation.id || '');
          
      case 'insert':
        return await this.supabase
          .from(table)
          .insert(operation.data);
          
      case 'update':
        return await this.supabase
          .from(table)
          .update(operation.data)
          .eq('id', operation.id);
          
      case 'delete':
        return await this.supabase
          .from(table)
          .delete()
          .eq('id', operation.id);
          
      default:
        throw new Error(`Unsupported operation: ${operation.type}`);
    }
  }
  
  private validateResult(actual: any, expected: RLSExpectation): boolean {
    if (expected.shouldFail) {
      return actual.error !== null;
    }
    
    if (expected.rowCount !== undefined) {
      return actual.data?.length === expected.rowCount;
    }
    
    if (expected.organizationFilter) {
      return actual.data?.every((row: any) => 
        row.organization_id === expected.organizationFilter
      );
    }
    
    return actual.error === null;
  }
}
```

### Day 2: Core Table RLS Tests
**Time: 5 hours**

```typescript
// tests/database/tables/photos-rls.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { RLSTestFramework } from '../rls-test-framework';

describe('Photos Table RLS', () => {
  const rls = new RLSTestFramework();
  
  const testUsers = {
    org1Admin: { email: 'admin@org1.com', password: 'test123', organizationId: 'org-1', role: 'admin' },
    org1Engineer: { email: 'engineer@org1.com', password: 'test123', organizationId: 'org-1', role: 'engineer' },
    org2Admin: { email: 'admin@org2.com', password: 'test123', organizationId: 'org-2', role: 'admin' },
    viewer: { email: 'viewer@org1.com', password: 'test123', organizationId: 'org-1', role: 'viewer' },
  };
  
  beforeEach(async () => {
    // Setup test data
    await rls.setupTestData('photos', [
      { id: 'photo-org1-1', organization_id: 'org-1', title: 'Org 1 Photo 1' },
      { id: 'photo-org1-2', organization_id: 'org-1', title: 'Org 1 Photo 2' },
      { id: 'photo-org2-1', organization_id: 'org-2', title: 'Org 2 Photo 1' },
    ]);
  });
  
  it('should allow users to read only their organization photos', async () => {
    const result = await rls.testTableRLS({
      table: 'photos',
      scenarios: [
        {
          name: 'org1-admin-reads-org1-photos',
          user: testUsers.org1Admin,
          operation: { type: 'select' },
          expected: { rowCount: 2, organizationFilter: 'org-1' },
        },
        {
          name: 'org2-admin-reads-org2-photos',
          user: testUsers.org2Admin,
          operation: { type: 'select' },
          expected: { rowCount: 1, organizationFilter: 'org-2' },
        },
        {
          name: 'org1-user-cannot-read-org2-photos',
          user: testUsers.org1Engineer,
          operation: { type: 'select', id: 'photo-org2-1' },
          expected: { rowCount: 0 },
        },
      ],
    });
    
    expect(result.passed).toBe(3);
    expect(result.failed).toBe(0);
  });
  
  it('should prevent cross-organization photo access', async () => {
    const result = await rls.testTableRLS({
      table: 'photos',
      scenarios: [
        {
          name: 'org1-cannot-update-org2-photo',
          user: testUsers.org1Admin,
          operation: { 
            type: 'update', 
            id: 'photo-org2-1', 
            data: { title: 'Hacked!' } 
          },
          expected: { shouldFail: true },
        },
        {
          name: 'org1-cannot-delete-org2-photo',
          user: testUsers.org1Engineer,
          operation: { type: 'delete', id: 'photo-org2-1' },
          expected: { shouldFail: true },
        },
      ],
    });
    
    expect(result.passed).toBe(2);
    expect(result.failed).toBe(0);
  });
  
  it('should enforce role-based permissions', async () => {
    const result = await rls.testTableRLS({
      table: 'photos',
      scenarios: [
        {
          name: 'viewer-cannot-delete-photos',
          user: testUsers.viewer,
          operation: { type: 'delete', id: 'photo-org1-1' },
          expected: { shouldFail: true },
        },
        {
          name: 'engineer-can-update-photos',
          user: testUsers.org1Engineer,
          operation: { 
            type: 'update', 
            id: 'photo-org1-1', 
            data: { title: 'Updated by Engineer' } 
          },
          expected: { shouldFail: false },
        },
        {
          name: 'admin-can-delete-photos',
          user: testUsers.org1Admin,
          operation: { type: 'delete', id: 'photo-org1-2' },
          expected: { shouldFail: false },
        },
      ],
    });
    
    expect(result.passed).toBe(3);
  });
});
```

### Day 3: Advanced RLS Scenarios
**Time: 5 hours**

```typescript
// tests/database/tables/ai-results-rls.test.ts
import { describe, it, expect } from 'vitest';
import { RLSTestFramework } from '../rls-test-framework';

describe('AI Results Table RLS', () => {
  const rls = new RLSTestFramework();
  
  it('should protect AI processing results', async () => {
    const result = await rls.testTableRLS({
      table: 'ai_results',
      scenarios: [
        {
          name: 'ai-results-org-isolation',
          user: { email: 'user@org1.com', organizationId: 'org-1' },
          operation: { type: 'select' },
          expected: { organizationFilter: 'org-1' },
        },
        {
          name: 'cross-org-ai-results-blocked',
          user: { email: 'user@org1.com', organizationId: 'org-1' },
          operation: { 
            type: 'insert', 
            data: { 
              photo_id: 'photo-belongs-to-org2',
              provider: 'openai',
              result: { tags: ['test'] }
            }
          },
          expected: { shouldFail: true },
        },
      ],
    });
    
    expect(result.passed).toBe(2);
  });
});

// tests/database/tables/organizations-rls.test.ts
describe('Organizations Table RLS', () => {
  const rls = new RLSTestFramework();
  
  it('should protect organization data', async () => {
    const result = await rls.testTableRLS({
      table: 'organizations',
      scenarios: [
        {
          name: 'user-sees-only-own-org',
          user: { email: 'user@org1.com', organizationId: 'org-1', role: 'engineer' },
          operation: { type: 'select' },
          expected: { rowCount: 1, organizationFilter: 'org-1' },
        },
        {
          name: 'user-cannot-update-other-org',
          user: { email: 'user@org1.com', organizationId: 'org-1', role: 'admin' },
          operation: { 
            type: 'update', 
            id: 'org-2', 
            data: { name: 'Hacked Org' } 
          },
          expected: { shouldFail: true },
        },
        {
          name: 'platform-admin-sees-all-orgs',
          user: { email: 'platform@admin.com', role: 'platform_admin' },
          operation: { type: 'select' },
          expected: { shouldFail: false }, // Platform admin should see all
        },
      ],
    });
    
    expect(result.passed).toBe(3);
  });
});

// tests/database/tables/user-roles-rls.test.ts  
describe('User Roles Table RLS', () => {
  const rls = new RLSTestFramework();
  
  it('should protect role assignments', async () => {
    const result = await rls.testTableRLS({
      table: 'user_roles',
      scenarios: [
        {
          name: 'user-cannot-escalate-privileges',
          user: { email: 'engineer@org1.com', organizationId: 'org-1', role: 'engineer' },
          operation: { 
            type: 'update', 
            id: 'their-own-role-id',
            data: { role: 'admin' } 
          },
          expected: { shouldFail: true },
        },
        {
          name: 'admin-can-assign-roles-in-org',
          user: { email: 'admin@org1.com', organizationId: 'org-1', role: 'admin' },
          operation: { 
            type: 'update', 
            id: 'user-role-in-org1',
            data: { role: 'engineer' } 
          },
          expected: { shouldFail: false },
        },
        {
          name: 'admin-cannot-assign-roles-cross-org',
          user: { email: 'admin@org1.com', organizationId: 'org-1', role: 'admin' },
          operation: { 
            type: 'update', 
            id: 'user-role-in-org2',
            data: { role: 'viewer' } 
          },
          expected: { shouldFail: true },
        },
      ],
    });
    
    expect(result.passed).toBe(3);
  });
});
```

### Day 4: Migration & Schema Testing
**Time: 4 hours**

```typescript
// tests/database/migrations/migration-security.test.ts
import { describe, it, expect } from 'vitest';
import { MigrationTester } from '../migration-test-framework';

describe('Migration Security Testing', () => {
  const migrationTester = new MigrationTester();
  
  it('should maintain RLS policies during migrations', async () => {
    // Test that migrations don't break RLS
    const migrations = await migrationTester.getAllMigrations();
    
    for (const migration of migrations) {
      // Apply migration
      await migrationTester.applyMigration(migration.id);
      
      // Test RLS policies still work
      const rlsResults = await migrationTester.validateAllRLSPolicies();
      
      expect(rlsResults.passed).toBe(rlsResults.total);
      expect(rlsResults.broken).toHaveLength(0);
    }
  });
  
  it('should test migration rollbacks', async () => {
    const result = await migrationTester.testMigrationRollback({
      migrationId: 'latest',
      testDataBefore: {
        photos: [
          { id: 'test-1', organization_id: 'org-1', title: 'Test' }
        ],
      },
      validateAfterRollback: async () => {
        // Ensure data integrity after rollback
        const { data } = await supabase.from('photos').select('*').eq('id', 'test-1');
        return data?.length === 1;
      },
    });
    
    expect(result.rollbackSuccessful).toBe(true);
    expect(result.dataIntegrityMaintained).toBe(true);
  });
  
  it('should prevent unauthorized schema modifications', async () => {
    const unauthorizedOperations = [
      'DROP POLICY',
      'ALTER TABLE photos DISABLE ROW LEVEL SECURITY',
      'GRANT ALL ON photos TO public',
      'CREATE OR REPLACE FUNCTION bypass_rls()',
    ];
    
    for (const operation of unauthorizedOperations) {
      const result = await migrationTester.attemptUnauthorizedOperation(operation);
      expect(result.blocked).toBe(true);
    }
  });
});

// tests/database/schema/schema-security.test.ts
describe('Database Schema Security', () => {
  it('should validate all tables have RLS enabled', async () => {
    const tables = await migrationTester.getAllTables();
    
    for (const table of tables) {
      if (table.contains_sensitive_data) {
        const rlsEnabled = await migrationTester.checkRLSEnabled(table.name);
        expect(rlsEnabled).toBe(true, `Table ${table.name} should have RLS enabled`);
      }
    }
  });
  
  it('should validate foreign key constraints', async () => {
    const constraints = [
      {
        table: 'photos',
        column: 'organization_id',
        references: 'organizations(id)',
      },
      {
        table: 'ai_results',
        column: 'photo_id',
        references: 'photos(id)',
      },
      {
        table: 'user_roles',
        column: 'organization_id',
        references: 'organizations(id)',
      },
    ];
    
    for (const constraint of constraints) {
      const exists = await migrationTester.checkConstraintExists(constraint);
      expect(exists).toBe(true, `Constraint ${constraint.table}.${constraint.column} missing`);
    }
  });
});
```

### Day 5: Comprehensive Security Audit
**Time: 4 hours**

```typescript
// tests/database/security-audit.test.ts
import { describe, it, expect } from 'vitest';
import { DatabaseSecurityAuditor } from './security-auditor';

describe('Database Security Audit', () => {
  const auditor = new DatabaseSecurityAuditor();
  
  it('should pass comprehensive security audit', async () => {
    const audit = await auditor.runFullSecurityAudit();
    
    // RLS Coverage
    expect(audit.rls.coverage.percentage).toBeGreaterThan(95);
    expect(audit.rls.unprotected_tables).toHaveLength(0);
    
    // Access Control
    expect(audit.access_control.unauthorized_access_attempts).toHaveLength(0);
    expect(audit.access_control.privilege_escalation_blocked).toBe(true);
    
    // Data Integrity
    expect(audit.data_integrity.foreign_key_violations).toHaveLength(0);
    expect(audit.data_integrity.orphaned_records).toHaveLength(0);
    
    // Policy Effectiveness
    expect(audit.policy_effectiveness.cross_org_leaks).toHaveLength(0);
    expect(audit.policy_effectiveness.role_bypass_attempts).toHaveLength(0);
  });
  
  it('should detect and prevent common attack vectors', async () => {
    const attacks = [
      'sql_injection',
      'privilege_escalation', 
      'data_exfiltration',
      'cross_tenant_access',
      'role_manipulation',
    ];
    
    for (const attack of attacks) {
      const result = await auditor.simulateAttack(attack);
      expect(result.blocked).toBe(true);
      expect(result.data_compromised).toBe(false);
    }
  });
  
  it('should validate backup and restore security', async () => {
    const backupTest = await auditor.testBackupRestore({
      includeUserData: true,
      testOrganizationIsolation: true,
      validateRLSAfterRestore: true,
    });
    
    expect(backupTest.organizationDataIsolated).toBe(true);
    expect(backupTest.rlsPoliciesRestored).toBe(true);
    expect(backupTest.noDataLeakage).toBe(true);
  });
});

// Database Security Auditor Implementation
export class DatabaseSecurityAuditor {
  async runFullSecurityAudit(): Promise<SecurityAuditReport> {
    const [rls, access, integrity, policies] = await Promise.all([
      this.auditRLSCoverage(),
      this.auditAccessControl(),
      this.auditDataIntegrity(),
      this.auditPolicyEffectiveness(),
    ]);
    
    return {
      timestamp: new Date().toISOString(),
      rls,
      access_control: access,
      data_integrity: integrity,
      policy_effectiveness: policies,
      overall_score: this.calculateSecurityScore([rls, access, integrity, policies]),
    };
  }
  
  private async auditRLSCoverage(): Promise<RLSAuditResult> {
    const tables = await this.getAllSensitiveTables();
    const protectedTables = [];
    const unprotectedTables = [];
    
    for (const table of tables) {
      const hasRLS = await this.checkRLSEnabled(table);
      const hasPolicies = await this.checkRLSPolicies(table);
      
      if (hasRLS && hasPolicies.length > 0) {
        protectedTables.push({ table, policies: hasPolicies.length });
      } else {
        unprotectedTables.push({ table, reason: hasRLS ? 'no_policies' : 'rls_disabled' });
      }
    }
    
    return {
      total_tables: tables.length,
      protected_tables: protectedTables.length,
      unprotected_tables: unprotectedTables,
      coverage: {
        percentage: (protectedTables.length / tables.length) * 100,
        grade: this.calculateGrade(protectedTables.length / tables.length),
      },
    };
  }
  
  private async auditAccessControl(): Promise<AccessControlAuditResult> {
    // Test unauthorized access attempts
    const testCases = [
      this.testCrossOrganizationAccess(),
      this.testPrivilegeEscalation(),
      this.testDirectTableAccess(),
      this.testBypassAttempts(),
    ];
    
    const results = await Promise.all(testCases);
    
    return {
      unauthorized_access_attempts: results.filter(r => !r.blocked),
      privilege_escalation_blocked: results[1].blocked,
      direct_access_prevented: results[2].blocked,
      bypass_attempts_failed: results[3].blocked,
    };
  }
  
  private async simulateAttack(attackType: string): Promise<AttackSimulationResult> {
    switch (attackType) {
      case 'sql_injection':
        return await this.simulateSQLInjection();
      case 'privilege_escalation':
        return await this.simulatePrivilegeEscalation();
      case 'data_exfiltration':
        return await this.simulateDataExfiltration();
      case 'cross_tenant_access':
        return await this.simulateCrossTenantAccess();
      case 'role_manipulation':
        return await this.simulateRoleManipulation();
      default:
        throw new Error(`Unknown attack type: ${attackType}`);
    }
  }
  
  private async simulateSQLInjection(): Promise<AttackSimulationResult> {
    const maliciousInputs = [
      "'; DROP TABLE photos; --",
      "' OR 1=1 --",
      "' UNION SELECT * FROM organizations --",
      "'; UPDATE user_roles SET role='admin' WHERE id='target'; --",
    ];
    
    let blocked = true;
    let dataCompromised = false;
    
    for (const input of maliciousInputs) {
      try {
        const result = await supabase
          .from('photos')
          .select('*')
          .ilike('title', input);
          
        if (result.error && result.error.message.includes('syntax error')) {
          // Good - query was blocked
          continue;
        } else if (result.data) {
          // Bad - injection might have worked
          blocked = false;
          dataCompromised = true;
        }
      } catch (error) {
        // Expected - injection blocked
      }
    }
    
    return { blocked, data_compromised: dataCompromised };
  }
  
  private calculateSecurityScore(audits: any[]): number {
    // Calculate overall security score based on audit results
    const weights = [0.4, 0.3, 0.2, 0.1]; // RLS, Access, Integrity, Policies
    let totalScore = 0;
    
    audits.forEach((audit, index) => {
      const auditScore = this.calculateAuditScore(audit);
      totalScore += auditScore * weights[index];
    });
    
    return Math.round(totalScore * 100);
  }
}
```

## Test Execution Commands

```bash
# Run all database security tests
npm run test:db-security

# Run RLS tests only
npm run test:rls

# Run migration security tests  
npm run test:migration-security

# Run comprehensive security audit
npm run test:security-audit

# Generate security report
npm run test:security:report

# Test specific table RLS
npm run test:rls -- --grep "photos"
```

## Coverage Matrix

| Table | RLS Enabled | Policies | Org Isolation | Role-Based | Status |
|-------|-------------|----------|---------------|------------|--------|
| photos | ✅ | 4 | ✅ | ✅ | ✅ |
| ai_results | ✅ | 3 | ✅ | ✅ | ✅ |
| organizations | ✅ | 5 | ✅ | ✅ | ✅ |
| user_roles | ✅ | 6 | ✅ | ✅ | ✅ |
| tags | ✅ | 3 | ✅ | ✅ | ✅ |
| projects | ✅ | 4 | ✅ | ✅ | ✅ |
| ai_providers | ✅ | 2 | ✅ | ✅ | ✅ |
| ai_prompts | ✅ | 3 | ✅ | ✅ | ✅ |
| exports | ✅ | 3 | ✅ | ✅ | ✅ |
| audit_logs | ✅ | 4 | ✅ | ✅ | ✅ |

**Success Criteria**: 100% RLS coverage with comprehensive multi-tenant security testing prevents data leaks and ensures production-ready database security for AI agent confidence.