# Contributing to LF9

Thank you for your interest in contributing to the LF9 Learning Field 9 infrastructure project!

## How to Contribute

### Reporting Issues

If you find bugs or have suggestions for improvements:

1. Check existing issues to avoid duplicates
2. Create a new issue with a clear description
3. Include steps to reproduce for bugs
4. Suggest specific improvements for enhancements

### Making Changes

1. **Fork the repository**
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Test your changes**:
   ```bash
   docker-compose down
   docker-compose up -d
   ```
5. **Commit your changes**:
   ```bash
   git commit -m "Add: description of your changes"
   ```
6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create a Pull Request**

### Types of Contributions Welcome

- **Documentation improvements** (German and English)
- **Bug fixes**
- **Service configuration improvements**
- **New service additions**
- **Security improvements**
- **Performance optimizations**

### Guidelines

- Keep changes focused and atomic
- Update documentation for any configuration changes
- Test all changes before submitting
- Follow existing code/configuration style
- Write clear commit messages

### Testing

Before submitting changes:

1. Ensure all services start successfully:
   ```bash
   docker-compose up -d
   docker-compose ps
   ```

2. Verify service connectivity:
   ```bash
   docker-compose logs [service-name]
   ```

3. Test any modified functionality

### Documentation

- Update both German (`Doku.md`) and English (`README.md`) documentation
- Keep documentation synchronized
- Include examples where helpful
- Update service tables if IP addresses or ports change

## Questions?

Feel free to open an issue for any questions about contributing!