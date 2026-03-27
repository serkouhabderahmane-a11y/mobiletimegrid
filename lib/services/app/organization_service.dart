import '../../models/organization/organization_model.dart';
import 'api_service.dart';

class OrganizationService {
  final ApiService _api;

  OrganizationService(this._api);

  Future<Organization> getOrganization() async {
    try {
      final response = await _api.get('/organization');
      return Organization.fromJson(response);
    } catch (_) {
      return _getMockOrganization();
    }
  }

  Organization _getMockOrganization() {
    return Organization(
      id: 'org-1',
      name: 'Time Grid',
      logoUrl: null,
      description: '''
Time Grid is a comprehensive employee management platform designed to streamline workforce operations. Our mission is to empower organizations with efficient tools for time tracking, attendance management, and employee onboarding.

Founded in 2020, we have grown to serve thousands of businesses across various industries. Our platform offers:

• Real-time attendance tracking
• Smart scheduling and shift management
• Comprehensive onboarding workflows
• Payroll integration
• Detailed reporting and analytics

We believe in creating tools that simplify complex HR processes while providing an excellent user experience for both administrators and employees.
      ''',
      email: 'contact@timegrid.com',
      phone: '+1 800 123 4567',
      website: 'https://timegrid.com',
      address: '123 Business Center',
      city: 'San Francisco',
      state: 'CA',
      zipCode: '94102',
      country: 'United States',
      foundedDate: DateTime(2020, 1, 1),
      employeeCount: 50,
      departments: [
        Department(id: 'dept-1', name: 'Engineering', employeeCount: 25),
        Department(id: 'dept-2', name: 'Sales', employeeCount: 10),
        Department(id: 'dept-3', name: 'Marketing', employeeCount: 8),
        Department(id: 'dept-4', name: 'Human Resources', employeeCount: 7),
      ],
      locations: [
        Location(
          id: 'loc-1',
          name: 'Headquarters',
          address: '123 Business Center',
          city: 'San Francisco',
          state: 'CA',
          zipCode: '94102',
          phone: '+1 800 123 4567',
        ),
        Location(
          id: 'loc-2',
          name: 'West Coast Office',
          address: '456 Tech Park',
          city: 'Los Angeles',
          state: 'CA',
          zipCode: '90001',
          phone: '+1 800 987 6543',
        ),
      ],
    );
  }
}
